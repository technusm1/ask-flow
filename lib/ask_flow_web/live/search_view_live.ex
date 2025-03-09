defmodule AskFlowWeb.SearchViewLive do
  alias AskFlow.QuestionsCache
  alias AskFlow.API.LLM
  use AskFlowWeb, :live_view

  alias AskFlow.Questions
  alias AskFlow.RecentSearchesCache

  require Logger

  @default_user_id 0
  @search_timeout 15_000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      _window = Phoenix.LiveView.get_connect_params(socket)
    end

    user_id = socket.assigns[:current_user] && socket.assigns.current_user.id || @default_user_id
    {recent_questions, recent_searches} =
      if user_id != @default_user_id do
        searches = RecentSearchesCache.get_recent_searches(user_id)
        questions = QuestionsCache.get_recent_questions(user_id)
        {questions, searches}
      else
        {[], []}
      end

    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:questions, [])
     |> assign(:loading, false)
     |> assign(:answers, [])
     |> assign(:ai_generated_answer, %{})
     |> assign(:error, nil)
     |> assign(:recent_questions, recent_questions)
     |> assign(:recent_searches, recent_searches)
     |> assign(:show_sort_dropdown, false)
     |> assign(:sort_by, "newest")}
  end

  @impl true
  def handle_params(%{"q" => query, "sort_by" => sort_by}, _uri, socket) when query != "" do
    # Cancel any existing search timer
    if socket.assigns[:search_timer] do
      Process.cancel_timer(socket.assigns.search_timer)
    end

    questions = sort_questions(socket.assigns.questions, sort_by)

    if query == socket.assigns.query do
      {:noreply, socket |> assign(:questions, questions)}
    else
      # Set a timeout for the search
      search_timer = Process.send_after(self(), :search_timeout, @search_timeout)

      Logger.info("Starting search for: #{query}")

      user_id = socket.assigns[:current_user] && socket.assigns.current_user.id || 0
      recent_searches = if user_id != 0 do
        {:ok, updated_searches} = RecentSearchesCache.add_recent_search(user_id, %{
          search_text: query,
          user_id: user_id
        })
        updated_searches
      else
        []
      end

      {:noreply,
      socket
      |> assign(:loading, true)
      |> assign(:query, query)
      |> assign(:error, nil)
      |> assign(:search_timer, search_timer)
      |> assign(:recent_searches, recent_searches)
      |> assign(:sort_by, sort_by)
      |> start_search_questions()}
    end
  end

  @impl true
  def handle_params(%{"q" => query}, uri, socket) when query != "" do
    handle_params(%{"q" => query, "sort_by" => "highest_score"}, uri, socket)
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_cast({:data, %ExOpenAI.Components.CreateChatCompletionResponse{} = response}, socket) do
    content_str = Enum.reduce(response.choices, "", fn choice, acc ->
      choice_content = choice |> Map.get(:delta, %{}) |> Map.get(:content, "")
      acc <> choice_content
    end)
    ai_answer_markdown = socket.assigns[:ai_generated_answer] |> Map.get("body_markdown", "")
    {:noreply,
    socket
    |> assign(:ai_generated_answer, %{
      "owner" => %{
        "display_name" => "AI",
        "profile_image" => "https://cdn.sstatic.net/Sites/stackoverflow/img/apple-touch-icon.png"
      },
      "body_markdown" => ai_answer_markdown <> content_str,
      "creation_date" => DateTime.utc_now() |> DateTime.to_unix()
    })}
  end

  @impl true
  def handle_cast(:finish, socket) do
    {:noreply, socket
    |> put_flash(:info, "Answer generated successfully")
    |> assign(:answer_loading, false)}
  end

  # Start streaming from OpenAI
  @impl true
  def handle_event("generate_answer_with_ai", _params, socket) do
    {:ok, _completion_response} = LLM.stream_response(self(), socket.assigns[:query], "")
    {:noreply, socket}
  end

  @impl true
  def handle_event("sort_questions", %{"sort_option" => sort_by}, socket) do
    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> push_patch(to: ~p"/search?q=#{socket.assigns.query}&sort_by=#{sort_by}")}
  end

  @impl true
  def handle_info({:search_questions, query}, socket) do
    Logger.info("Executing search for: #{query}")

    case Questions.search_stack_overflow(query) do
      {:ok, questions} when is_list(questions) and questions != [] ->
        Logger.info("Search successful, found #{length(questions)} results")

        # Cancel the search timeout
        if socket.assigns[:search_timer] do
          Process.cancel_timer(socket.assigns.search_timer)
        end

        sorted_questions = sort_questions(questions, socket.assigns.sort_by)

        {:noreply,
         socket
         |> assign(:search_timer, nil)
         |> assign(:loading, false)
         |> assign(:questions, sorted_questions)}

      {:ok, []} ->
        Logger.warning("No results found for '#{query}'")

        # Cancel the search timeout
        if socket.assigns[:search_timer] do
          Process.cancel_timer(socket.assigns.search_timer)
        end

        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:search_timer, nil)
         |> put_flash(:error, "No results found for '#{query}'")}

      {:error, reason} ->
        Logger.error("Error searching: #{reason}")

        # Cancel the search timeout
        if socket.assigns[:search_timer] do
          Process.cancel_timer(socket.assigns.search_timer)
        end

        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:search_timer, nil)
         |> put_flash(:error, "Error searching: #{reason}")}
    end
  end

  @impl true
  def handle_info(:search_timeout, socket) do
    Logger.error("Search timeout for query: #{socket.assigns.query}")

    {:noreply,
     socket
     |> assign(:loading, false)
     |> assign(:search_timer, nil)
     |> put_flash(:error, "Search timed out. Please try again or try a different query.")}
  end

  defp start_search_questions(socket) do
    query = socket.assigns.query
    send(self(), {:search_questions, query})
    socket
  end

  defp sort_questions(questions, ""), do: sort_questions(questions, "highest_score")
  defp sort_questions(questions, "oldest"), do: Enum.sort_by(questions, & &1["creation_date"], :asc)
  defp sort_questions(questions, "newest"), do: Enum.sort_by(questions, & &1["creation_date"], :desc)
  defp sort_questions(questions, "highest_score"), do: Enum.sort_by(questions, & &1["score"], :desc)
  defp sort_questions(questions, "lowest_score"), do: Enum.sort_by(questions, & &1["score"], :asc)
  defp sort_questions(questions, "popularity"), do: Enum.sort_by(questions, & &1["view_count"], :desc)
  defp sort_questions(questions, "highest_llm_score"), do: Enum.sort_by(questions, & &1["llm_score"], :desc)
  defp sort_questions(questions, "lowest_llm_score"), do: Enum.sort_by(questions, & &1["llm_score"], :asc)
end
