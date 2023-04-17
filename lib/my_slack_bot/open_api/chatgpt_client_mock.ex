defmodule MySlackBot.OpenApi.ChatgptClientMock do
  def create_completion(_prompt) do
    {:ok,
      %{
        "choices" => [
          %{
            "finish_reason" => "stop",
            "index" => 0,
            "logprobs" => nil,
            "text" => "\n\nQ: Why did the scarecrow win the Nobel Prize?\nA: Because he was outstanding in his field!"
          }
        ],
        "created" => 1681175777,
        "id" => "cmpl-73wuHnQcjyhj7RXAqzCm0rYkPNq2G",
        "model" => "text-davinci-003",
        "object" => "text_completion",
        "usage" => %{
          "completion_tokens" => 25,
          "prompt_tokens" => 4,
          "total_tokens" => 29
        }
      }}
  end

  def create_chat_completion(_content) do
    {:ok,
      %{
        "choices" => [
          %{
            "finish_reason" => "stop",
            "index" => 0,
            "message" => %{
              "content" => "\"The best way to predict your future is to create it.\" - Abraham Lincoln",
              "role" => "assistant"
            }
          }
        ],
        "created" => 1681178550,
        "id" => "chatcmpl-73xd0FLs5hAUlWy2O1rlM30QQvORW",
        "model" => "gpt-3.5-turbo-0301",
        "object" => "chat.completion",
        "usage" => %{
          "completion_tokens" => 15,
          "prompt_tokens" => 12,
          "total_tokens" => 27
        }
      }}
  end
end
