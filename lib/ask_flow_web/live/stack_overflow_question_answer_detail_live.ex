defmodule AskFlowWeb.StackOverflowQuestionAnswerDetailLive do
  alias AskFlow.API.LLM
  alias AskFlow.QuestionsCache
  alias AskFlow.Questions
  require Logger
  use AskFlowWeb, :live_view

  @impl true
  def mount(%{"question_id" => question_id} = params, _session, socket) do
    if connected?(socket) do
      # Fetch question details from Stack Overflow API
      case Questions.get_stack_overflow_question(question_id) do
        {:ok, question_data} ->
          send(self(), {:fetch_answers, question_id, question_data})

          # Cache the question
          user_id = (socket.assigns[:current_user] && socket.assigns.current_user.id) || 0

          if user_id != 0 do
            QuestionsCache.add_recent_question(user_id, %{
              question_id: question_data["question_id"],
              question_title: question_data["title"],
              user_id: user_id
            })
          end

          {:ok,
           socket
           |> assign(:question, question_data)
           |> assign(:sort_by, Map.get(params, "sort_by", ""))
           |> assign(:loading, false)
           |> assign(:answer_loading, true)
           |> assign(:ai_generated_answer, %{})
           |> assign(:llm_ranking_in_progress, false)
           |> assign(:answers, [])}

        {:error, reason} ->
          {:ok,
           socket
           |> put_flash(:error, "Failed to load question details: #{reason}")
           |> assign(:loading, false)}
      end
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def handle_cast({:data, %ExOpenAI.Components.CreateChatCompletionResponse{} = response}, socket) do
    content_str =
      Enum.reduce(response.choices, "", fn choice, acc ->
        choice_content = choice |> Map.get(:delta, %{}) |> Map.get(:content, "")
        acc <> choice_content
      end)

    ai_answer_markdown = socket.assigns[:ai_generated_answer] |> Map.get("body_markdown", "")

    {:noreply,
     socket
     |> assign(:ai_generated_answer, %{
       "owner" => %{
         "display_name" => "Your friendly AI",
         "profile_image" => "/images/robot.png"
       },
       "body_markdown" => ai_answer_markdown <> content_str,
       "creation_date" => DateTime.utc_now() |> DateTime.to_unix()
     })}
  end

  @impl true
  def handle_cast(:finish, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Answer generated successfully")
     |> assign(:answer_loading, false)}
  end

  @impl true
  def handle_event("sort_answers", %{"sort_option" => sort_option}, socket) do
    Logger.info("Sorting answers by: #{sort_option}")
    sorted_answers = sort_answers(socket.assigns.answers, sort_option)

    {:noreply,
     socket
     |> assign(:answers, sorted_answers)
     |> assign(:sort_by, sort_option)
     |> push_patch(
       to:
         ~p"/stackoverflow/questions/#{socket.assigns.question["question_id"]}?sort_by=#{sort_option}"
     )}
  end

  # Start streaming from OpenAI
  @impl true
  def handle_event("generate_answer_with_ai", _params, socket) do
    {:ok, _completion_response} =
      LLM.stream_response(
        self(),
        socket.assigns[:question]["title"],
        socket.assigns[:question]["body_markdown"]
      )

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_async(:llm_ranking, {:ok, ranked_answers}, socket) do
    {:noreply,
     socket
     |> assign(:answers, ranked_answers)
     |> assign(:llm_ranking_in_progress, false)}
  end

  @impl true
  def handle_async(:llm_ranking, {:error, reason}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Failed to rank answers: #{reason}")
     |> assign(:llm_ranking_in_progress, false)}
  end

  @impl true
  def handle_info({:fetch_answers, question_id, question}, socket) do
    Logger.info("Fetching answers for question: #{question_id}")

    case Questions.get_answers(question_id) do
      {:ok, answers} ->
        Logger.info("Got #{length(answers)} answers for question #{question_id}")

        {:noreply,
         socket
         |> assign(:answer_loading, false)
         |> assign(:question, question)
         |> assign(:answers, answers)
         |> assign(:recent_questions, [])
         |> assign(:llm_ranking_in_progress, true)
         |> start_async(:llm_ranking, fn -> rank_by_llm(question, answers) end)
         |> push_event("sort_answers", %{"sort_option" => socket.assigns.sort_by})}
    end
  end

  defp rank_by_llm(question, answers) do
    Enum.map(answers, fn answer ->
      llm_score = LLM.get_llm_score(question, answer)
      Map.put(answer, "llm_score", llm_score)
    end)
  end

  defp sort_answers(answers, "newest"), do: Enum.sort_by(answers, & &1["creation_date"], :desc)
  defp sort_answers(answers, "oldest"), do: Enum.sort_by(answers, & &1["creation_date"], :asc)
  defp sort_answers(answers, "highest_score"), do: Enum.sort_by(answers, & &1["score"], :desc)
  defp sort_answers(answers, "lowest_score"), do: Enum.sort_by(answers, & &1["score"], :asc)
  defp sort_answers(answers, ""), do: answers

  defp sort_answers(answers, "highest_llm_score"),
    do: Enum.sort_by(answers, & &1["llm_score"], :desc)

  defp sort_answers(answers, "lowest_llm_score"),
    do: Enum.sort_by(answers, & &1["llm_score"], :asc)
end
