defmodule MySlackBot.ChatgptPrompts do
  import Ecto.Query, warn: false

  require Logger

  alias MySlackBot.Repo
  alias MySlackBot.Chatgpt.ChatgptPrompt
  alias MySlackBot.Chatgpt.ChatgptPromptHistory
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

  def add_chatgpt_prompt_history(gpt_prompt_id, content) do
    %ChatgptPromptHistory{}
      |> ChatgptPromptHistory.changeset(%{gpt_prompt_id: gpt_prompt_id, content: content})
      |> Repo.insert()
  end

  def get_chatgpt_prompt_history(id) do
    ChatgptPromptHistory
      |> where([r], r.id == ^id)
      |> Repo.one()
      |> case do
        nil -> {:error, "ChatgptPromptHistory: #{id} not found"}
        prompt_history -> {:ok, prompt_history}
      end
  end

  def delete_chatgpt_prompt_history(id) do
    case get_chatgpt_prompt_history(id) do
      {:ok, prompt_history} -> Repo.delete(prompt_history)
      {:error, error} -> {:error, error}
    end
  end

  def list_chatgpt_prompt_histories(gpt_prompt_id) do
    ChatgptPromptHistory
      |> where([r], r.gpt_prompt_id == ^gpt_prompt_id)
      |> Repo.all()
      |> then(fn histories -> {:ok, histories} end)
  end

  def truncate_chatgpt_prompt_histories(gpt_prompt_id, max_count) do
    ChatgptPromptHistory
      |> where([r], r.gpt_prompt_id == ^gpt_prompt_id)
      |> Repo.aggregate(:count)
      |> case do
        count when count > max_count ->
          ChatgptPromptHistory
          |> where([r], r.gpt_prompt_id == ^gpt_prompt_id)
          |> order_by([r], asc: r.inserted_at)
          |> limit(^(count - max_count))
          |> Repo.all()
          |> Enum.map(fn history -> Repo.delete(history) end)
          {:ok, "ChatgptPromptHistory: #{gpt_prompt_id} truncated"}
        _ ->
          {:ok, "ChatgptPromptHistory: #{gpt_prompt_id} not truncated"}
      end
  end
end
