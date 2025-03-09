defmodule AskFlow.QuestionsCache do
  @moduledoc """
  Cache for recent questions.
  """

  require Logger
  alias AskFlow.Questions

  @cache_name :questions_cache
  @max_recent_questions 5

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
    }
  end

  @doc """
  Start the cache.
  """
  def start_link(_opts) do
    Cachex.start_link(@cache_name)
  end

  @doc """
  Get recent questions for a user.
  """
  def get_recent_questions(user_id) do
    recent_questions =
      case Cachex.get(@cache_name, user_id) do
        {:ok, nil} -> []
        {:ok, questions} -> questions
        {:error, error} ->
          Logger.error("Failed to get recent questions from cache: #{inspect(error)}")
          []
      end
    if Enum.empty?(recent_questions) do
      # Load recent questions from the database
      Questions.get_recent_questions(user_id)
    else
      recent_questions
    end
  end

  @doc """
  Add a question to the recent questions list for a user.
  """
  def add_recent_question(user_id, question) do
    # Get current recent questions
    recent_questions = get_recent_questions(user_id)

    # Add the new question to the front of the list
    updated_questions =
      [question | recent_questions]
      |> Stream.uniq_by(fn q -> q.question_id end)  # Remove duplicates
      |> Enum.take(@max_recent_questions)   # Keep only the most recent questions

    # Update the cache
    case Cachex.put(@cache_name, user_id, updated_questions) do
      {:ok, true} ->
        # Also persist to database
        persist_question(question)
        {:ok, updated_questions}
      {:error, error} ->
        Logger.error("Failed to add recent question to cache: #{inspect(error)}")
        {:error, "Failed to add recent question to cache"}
    end
  end

  # Persist a question to the database.
  defp persist_question(%{question_id: question_id, question_title: title, user_id: user_id}) do
    # Check if the question already exists
    case Questions.get_question_by_title_and_user(title, user_id) do
      nil ->
        # Create a new question
        Questions.create_question(%{
          question_id: question_id,
          question_title: title,
          user_id: user_id
        })
      question ->
        # Question already exists, set its updated_at timestamp
        Questions.change_question(question, %{updated_at: DateTime.utc_now()})

    end
  end
  defp persist_question(question) do
    Logger.error("Invalid question format: #{inspect(question)}")
    {:error, "Invalid question format"}
  end
end
