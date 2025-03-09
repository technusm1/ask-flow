defmodule AskFlow.QuestionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AskFlow.Questions` context.
  """

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title",
        user_id: "some user_id"
      })
      |> AskFlow.Questions.create_question()

    question
  end
end
