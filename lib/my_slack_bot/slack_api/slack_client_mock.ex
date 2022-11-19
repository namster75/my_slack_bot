defmodule MySlackBot.SlackApi.SlackClientMock do
  def send_message(_channel_id, _text) do
    {:ok, "mocked send_message"}
  end
end
