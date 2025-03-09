defmodule AskFlow.Repo do
  use Ecto.Repo,
    otp_app: :ask_flow,
    adapter: Ecto.Adapters.Postgres
end
