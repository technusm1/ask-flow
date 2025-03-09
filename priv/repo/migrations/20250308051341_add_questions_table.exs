defmodule AskFlow.Repo.Migrations.AddQuestionsTable do
  use Ecto.Migration

  def change do
    create table(:stackoverflow_questions, primary_key: false) do
      add :question_id, :integer, primary_key: true
      add :question_title, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:stackoverflow_questions, [:user_id])
  end
end
