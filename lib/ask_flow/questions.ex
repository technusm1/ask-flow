defmodule AskFlow.Questions do
  @moduledoc """
  The Questions context.
  """

  import Ecto.Query, warn: false
  alias AskFlow.Searches.RecentSearch
  alias AskFlow.Repo

  alias AskFlow.Questions.Question
  alias AskFlow.API.StackOverflow

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions do
    Repo.all(Question)
  end

  @doc """
  Gets a single question.

  Raises if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

  """
  def get_question!(id), do: Repo.get!(Question, id)

  @doc """
  Gets a question by title and user_id.
  """
  def get_question_by_title_and_user(title, user_id) do
    Repo.get_by(Question, question_title: title, user_id: user_id)
  end

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, ...}

  """
  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, ...}

  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, ...}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns a data structure for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Todo{...}

  """
  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
    |> Repo.update()
  end

  @doc """
  Get recent searches for a user.
  """
  def get_recent_searches(user_id) do
    from(s in RecentSearch,
      where: s.user_id == ^user_id,
      order_by: [desc: s.updated_at],
      limit: 5
    )
    |> Repo.all()
  end

  @doc """
  Gets a question by title and user_id.
  """
  def get_recent_search_by_text_and_user(search_text, user_id) do
    Repo.get_by(RecentSearch, search_text: search_text, user_id: user_id)
  end

  @doc """
  Creates a search.

  ## Examples

      iex> create_search(%{field: value})
      {:ok, %RecentSearch{}}

      iex> create_search(%{field: bad_value})
      {:error, ...}

  """
  def create_search(attrs \\ %{}) do
    %RecentSearch{}
    |> RecentSearch.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns a data structure for tracking search changes.

  ## Examples

      iex> change_search(search)
      %Todo{...}

  """
  def change_search(%RecentSearch{} = search, attrs \\ %{}) do
    RecentSearch.changeset(search, attrs)
    |> Repo.update()
  end

  @doc """
  Search for questions on Stack Overflow.
  """
  def search_stack_overflow(query) do
    StackOverflow.search_questions(query)
  end

  @doc """
  Get answers for a question from Stack Overflow.
  """
  def get_answers(question_id) do
    StackOverflow.get_answers(question_id)
  end

  @doc """
  Get a question from Stack Overflow.
  """
  def get_stack_overflow_question(question_id) do
    StackOverflow.get_question(question_id)
  end

  @doc """
  Get recent questions for a user.
  """
  def get_recent_questions(user_id) do
    from(q in Question,
      where: q.user_id == ^user_id,
      order_by: [desc: q.updated_at],
      limit: 5
    )
    |> Repo.all()
  end
end
