defmodule MySlackBot.ChatgptPrompts do
  import Ecto.Query, warn: false

  require Logger

  alias MySlackBot.Repo
  alias MySlackBot.Chatgpt.ChatgptPrompt
  alias MySlackBot.SlackApi.SlackBot

  def add_chatgpt_prompt(channel_id, message) do
    with {:ok, channel} <- SlackBot.get_channel(channel_id) do
      %ChatgptPrompt{}
      |> ChatgptPrompt.changeset(%{message: message, slack_channel_id: channel.id})
      |> Repo.insert()
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_chatgpt_prompt(channel_id, message) do
    with {:ok, channel} <- SlackBot.get_channel(channel_id) do
      ChatgptPrompt
      |> where([p], p.message == ^message and p.slack_channel_id == ^channel.id)
      |> Repo.one()
      |> case do
        nil -> {:error, "message: #{message} not found"}
        prompt -> {:ok, prompt}
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  def delete_chatgpt_prompt(channel_id, message) do
    with {:ok, channel} <- SlackBot.get_channel(channel_id) do
      ChatgptPrompt
      |> where([p], p.message == ^message and p.slack_channel_id == ^channel.id)
      |> Repo.one()
      |> case do
        nil -> {:error, "message: #{message} not found"}
        prompt -> Repo.delete(prompt)
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  def list_chatgpt_prompts(channel_id) do
    with {:ok, channel} <- SlackBot.get_channel(channel_id) do
      prompts =
        ChatgptPrompt
        |> where([p], p.slack_channel_id == ^channel.id)
        |> Repo.all()

      {:ok, prompts}
    else
      {:error, error} -> {:error, error}
    end
  end
end
