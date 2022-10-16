defmodule MySlackBot.SlackApi.SlackClient do
  def send_message(channel_id, text) do
    json_body = %{
      "channel" => channel_id,
      "text" => text
    }
    |> Jason.encode!()

    {:ok, _} = HTTPoison.post("https://slack.com/api/chat.postMessage", json_body, build_headers())
  end

  defp build_headers do
    %{
      "Content-Type" => "application/json; charset=utf-8",
      "Authorization" => "Bearer #{System.fetch_env!("SLACK_BOT_TOKEN")}"
    }
  end
end
