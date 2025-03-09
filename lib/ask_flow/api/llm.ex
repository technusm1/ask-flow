defmodule AskFlow.API.LLM do
  @moduledoc """
  Integration with LLM (OpenAI-compatible API).
  """
  alias ExOpenAI.Components.ChatCompletionRequestSystemMessage

  require Logger

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
