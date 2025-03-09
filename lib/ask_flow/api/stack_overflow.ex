defmodule AskFlow.API.StackOverflow do
  @moduledoc """
  Client for the Stack Overflow API.
  """

  require Logger

  @base_url "https://api.stackexchange.com/2.3"
  # @base_url "http://localhost:8000"
  @user_agent "Askflow/1.0"
  @receive_timeout 10_000
  @default_params %{
    "site" => "stackoverflow"
  }

  @doc """
  Search for questions on Stack Overflow.
  """
  def search_questions(query) do
    Logger.info("Searching Stack Overflow for: #{query}")

    # Decode HTML entities in the query
    decoded_query =
      query
      |> HtmlEntities.decode()
      # Replace smart quotes with straight quotes
      |> String.replace(~r/["""]/, "\"")

    Logger.debug("Decoded query: #{decoded_query}")

    # Keep the search simple but include required parameters
    params =
      Map.merge(@default_params, %{
        # Search in titles
        "intitle" => decoded_query,
        "sort_by" => "relevance",
        "order" => "desc"
      })

    # Use simple search endpoint
    url = "#{@base_url}/search"
    Logger.debug("Search params: #{inspect(params)}")
    Logger.debug("Search URL: #{url}")

    case make_request(url, params) do
      {:ok, body} ->
        items = body["items"] || []
        # Process items to ensure proper content rendering
        processed_items = Enum.map(items, &process_item/1)
        Logger.info("Search successful, found #{length(items)} results")
        {:ok, processed_items}

      {:error, reason} ->
        Logger.error("Search failed: #{reason}")
        {:error, reason}
    end
  end

  @doc """
  Get answers for a specific question by its ID.
  """
  def get_answers(question_id) do
    Logger.info("Getting answers for question: #{question_id}")

    params =
      Map.merge(@default_params, %{
        # Sort by relevance
        "sort_by" => "relevance",
        # Highest relevance first
        "order" => "desc",
        # Filter to include body_markdown field in the question + answers
        "filter" => "!6WPIomnJRWnar"
      })

    url = "#{@base_url}/questions/#{question_id}/answers"

    result =
      case make_request(url, params) do
        {:ok, body} ->
          items = body["items"] || []
          # Process items to ensure proper content rendering
          processed_items = Enum.map(items, &process_item/1)
          Logger.info("Search successful, found #{length(items)} results")
          {:ok, processed_items}

        {:error, reason} ->
          Logger.error("Failed to get answers: #{reason}")
          # Return empty list instead of error
          {:ok, []}
      end

    Logger.info("Get answers completed")
    result
  end

  @doc """
  Get a specific question by its ID.
  """
  def get_question(question_id) do
    Logger.info("Getting question: #{question_id}")

    params = Map.merge(@default_params, %{
      "filter" => "!6WPIomnJRWnar"
    })

    url = "#{@base_url}/questions/#{question_id}"

    result =
      case make_request(url, params) do
        {:ok, body} ->
          case body["items"] do
            [question | _] ->
              Logger.info("Got question #{question_id}")
              {:ok, process_item(question)}

            _ ->
              Logger.error("Question #{question_id} not found")
              {:error, "Question not found"}
          end

        {:error, reason} ->
          Logger.error("Failed to get question: #{reason}")
          {:error, reason}
      end

    Logger.info("Get question completed")
    result
  end

    # Process an individual item to ensure proper content rendering
    defp process_item(item) do
      item
      |> process_title()
      |> process_owner()
    end

    defp process_title(item) do
      item
      |> Map.update("title", "", &HtmlEntities.decode/1)
    end

    # Process owner information
    defp process_owner(%{"owner" => owner} = item) when is_map(owner) do
      processed_owner =
        owner
        |> Map.update("display_name", "", &HtmlEntities.decode/1)

      Map.put(item, "owner", processed_owner)
    end

    defp process_owner(item), do: item

  # Make a request to the Stack Overflow API using Finch
  defp make_request(url, params) do
    # Convert params to query string
    query_string = URI.encode_query(params)
    full_url = "#{url}?#{query_string}"
    Logger.debug("Making request to: #{full_url}")

    headers = [
      {"accept", "application/json"},
      {"user-agent", @user_agent}
    ]

    # Use Finch to make the request
    request = Finch.build(:get, full_url, headers)

    Logger.debug("Sending request...")
    start_time = System.monotonic_time(:millisecond)

    result =
      case Finch.request(request, AskFlow.Finch, receive_timeout: @receive_timeout) do
        {:ok, %Finch.Response{status: 200, body: body}} ->
          elapsed = System.monotonic_time(:millisecond) - start_time
          Logger.debug("Request successful in #{elapsed}ms")
          {:ok, JSON.decode!(body)}

        {:ok, %Finch.Response{status: status, body: body}} ->
          elapsed = System.monotonic_time(:millisecond) - start_time

          Logger.error(
            "Stack Overflow API returned status code: #{status} in #{elapsed}ms, body: #{body}"
          )

          {:error, "Stack Overflow API error: #{status}"}

        {:error, reason} ->
          elapsed = System.monotonic_time(:millisecond) - start_time
          Logger.error("Stack Overflow API error after #{elapsed}ms: #{inspect(reason)}")
          {:error, "Stack Overflow API error: #{inspect(reason)}"}
      end

    Logger.debug("Request completed")
    result
  rescue
    e ->
      Logger.error("Error making request to Stack Overflow API: #{inspect(e)}")
      {:error, "Error making request to Stack Overflow API: #{inspect(e)}"}
  end
end
