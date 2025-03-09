defmodule AskFlow.Repo.Migrations.AddRecentSearchesTable do
  use Ecto.Migration

  def change do
    create table(:recent_searches) do
      add :search_text, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    # Make search_text and user_id combination unique since they form the primary key
    create unique_index(:recent_searches, [:search_text, :user_id])
  end
end
