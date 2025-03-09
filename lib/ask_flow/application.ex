defmodule AskFlow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
alias AskFlow.RecentSearchesCache
alias AskFlow.QuestionsCache

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AskFlowWeb.Telemetry,
      AskFlow.Repo,
      {DNSCluster, query: Application.get_env(:ask_flow, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AskFlow.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AskFlow.Finch},
      # Start Cache for caching recent questions and searches
      QuestionsCache,
      RecentSearchesCache,
      # Start to serve requests, typically the last entry
      AskFlowWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AskFlow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AskFlowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
