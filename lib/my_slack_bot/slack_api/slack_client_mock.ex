defmodule MySlackBot.SlackApi.SlackClientMock do
  def send_message(_channel_id, _text) do
    {:ok, "mocked send_message"}
  end

  def list_users do
    {:ok, %{
      "ok" => true,
      "members" => [
        %{
          "deleted" => false,
          "id" => "U01A2B3C4D",
          "profile" => %{
            "display_name" => "User 1",
          }
        },
        %{
          "deleted" => false,
          "id" => "U01A2B3C4E",
          "profile" => %{
            "display_name" => "User 2",
          }
        }
      ]
    }}
  end
end
