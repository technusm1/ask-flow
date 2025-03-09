defmodule AskFlow.RecentSearchesCache do
  @moduledoc """
  Cache for recent searches.
  """

  require Logger
  alias AskFlow.Questions

  @cache_name :recent_searches_cache
  @max_recent_searches 5

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
  Get recent searches for a user.
  """
  def get_recent_searches(user_id) do
    recent_searches =
      case Cachex.get(@cache_name, user_id) do
        {:ok, nil} -> []
        {:ok, searches} -> searches
        {:error, error} ->
          Logger.error("Failed to get recent searches from cache: #{inspect(error)}")
          []
      end
    if Enum.empty?(recent_searches) do
      # Load recent searches from the database
      Questions.get_recent_searches(user_id)
    else
      recent_searches
    end
  end

  @doc """
  Add a search to the recent searches list for a user.
  """
  def add_recent_search(user_id, search) do
    # Get current recent searches
    recent_searches = get_recent_searches(user_id)

    # Add the new search to the front of the list
    updated_searches =
      [search | recent_searches]
      |> Stream.uniq_by(fn s -> s.search_text end)  # Remove duplicates
      |> Enum.take(@max_recent_searches)   # Keep only the most recent searches

    # Update the cache
    case Cachex.put(@cache_name, user_id, updated_searches) do
      {:ok, true} ->
        # Also persist to database
        persist_search(search)
        {:ok, updated_searches}
      {:error, error} ->
        Logger.error("Failed to add recent search to cache: #{inspect(error)}")
        {:error, "Failed to add recent search to cache"}
    end
  end

  # Persist a search to the database.
  defp persist_search(%{search_text: search_text, user_id: user_id}) do
    # Check if the search already exists
    case Questions.get_recent_search_by_text_and_user(search_text, user_id) do
      nil ->
        # Create a new search
        Questions.create_search(%{
          search_text: search_text,
          user_id: user_id
        })
      search ->
        # Search already exists, set its updated_at timestamp
        Questions.change_search(search, %{updated_at: DateTime.utc_now()})
    end
  end
  defp persist_search(search) do
    Logger.error("Invalid search format: #{inspect(search)}")
    {:error, "Invalid search format"}
  end
end
