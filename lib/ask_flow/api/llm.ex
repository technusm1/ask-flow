defmodule AskFlow.API.LLM do
  @moduledoc """
  Integration with LLM (OpenAI-compatible API).
  """
  alias ExOpenAI.Components.ChatCompletionRequestSystemMessage

  require Logger

  def get_llm_score(question, answer) do
    options = [
      temperature: 1.0,
      base_url: System.get_env("OPENAI_API_URL", "http://localhost:1234/v1"),
    ]

    question_title = question["title"]
    question_body = question["body_markdown"]
    answer_body = answer["body_markdown"]

    {:ok, completion_response} =
      ExOpenAI.Chat.create_chat_completion(
        [
          %ChatCompletionRequestSystemMessage{
            content:
              """
              You are a highly skilled programmer who can judge the quality of an answer, given a question.
              You are a top-rated Stack Overflow expert.
              You are judging the answer for the following question:

              Question Title: #{question_title}
              Question Body (Markdown):
              #{question_body}

              Answer Body (Markdown):
              #{answer_body}

              Your reply should only contain the score of the answer out of 100.
              """,
            role: :system
          }
        ],
        "gpt-3.5-turbo",
        options
      )

    Enum.at(completion_response.choices, 0, %{})
    |> Map.get(:message, %{})
    |> Map.get(:content, "-1")
    |> String.to_integer()
  end

  def stream_response(pid, question_title, question_body) do
    Logger.info("Generating answer with AI")

    options = [
      temperature: 1.0,
      base_url: System.get_env("OPENAI_API_URL", "http://localhost:1234/v1"),
      stream: true,
      stream_to: pid
    ]

    ExOpenAI.Chat.create_chat_completion(
        [
          %ChatCompletionRequestSystemMessage{
            content: """
            You are a highly skilled programmer who can answer any programming related questions.
            You are a top-rated Stack Overflow expert.
            You are answering the following question:

            Title: #{question_title}
            Body (Markdown):
            #{question_body}

            Make sure to generate all answers in a nicely-formatted markdown format.
            Be as accurate as possible. Always begin with plaintext.
            Generate just the answer, don't generate anything extra.
            """,
            role: :system
          }
        ],
        "gpt-3.5-turbo",
        options
      )
  end
end
