defmodule AskFlow.Searches.RecentSearch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "recent_searches" do
    field :search_text, :string, primary_key: true
    belongs_to :user, AskFlow.Accounts.User, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(recent_search, attrs) do
    recent_search
    |> cast(attrs, [:search_text, :user_id, :updated_at, :inserted_at])
    |> validate_required([:search_text, :user_id])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:search_text, :user_id])
  end
end
