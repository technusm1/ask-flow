defmodule AskFlow.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:question_id, :integer, autogenerate: false}
  schema "stackoverflow_questions" do
    field :question_title, :string

    belongs_to :user, AskFlow.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question_title, :question_id, :user_id, :updated_at, :inserted_at])
    |> validate_required([:question_id, :question_title, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
