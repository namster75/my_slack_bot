defmodule MySlackBot.OpenApi.ChatgptClient do
  def create_completion(prompt) do
    json_body = %{
      "model" => "text-davinci-003",
      "prompt" => prompt,
      "max_tokens" => 500,
      "temperature" => 0,
    }
    |> Jason.encode!()

    case HTTPoison.post("https://api.openai.com/v1/completions", json_body, build_headers()) do
      {:ok, response} -> {:ok, Jason.decode!(response.body)}
      {:error, error} -> {:error, error}
    end
  end

  def create_chat_completion(messages) do
    json_body = %{
      "model" => "gpt-3.5-turbo",
      "messages" => messages
    }
    |> Jason.encode!()

    case HTTPoison.post("https://api.openai.com/v1/chat/completions", json_body, build_headers()) do
      {:ok, response} -> {:ok, Jason.decode!(response.body)}
      {:error, error} -> {:error, error}
    end
  end

  defp build_headers do
    %{
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{System.fetch_env!("OPENAPI_KEY")}"
    }
  end
end
