defmodule MySlackBot.ChatgptPromptsTest do
  use MySlackBot.DataCase

  alias MySlackBot.ChatgptPrompts
  alias MySlackBot.SlackApi.SlackBot

  setup do
    {:ok, channel} = SlackBot.add_channel("C01BQJZLZLQ", "general")

    {:ok, channel: channel}
  end

  describe "add_chatgpt_prompt/2" do
    test "adds a new chatgpt_prompt", %{channel: channel} do
      assert {:ok, prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert prompt.message == "test"
      assert prompt.slack_channel_id == channel.id
    end

    test "fails to add a new chatgpt_prompt with nil message", %{channel: channel} do
      assert {:error, _error} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, nil)
    end

    test "fails to add a new chatgpt_prompt with invalid channel_id" do
      assert {:error, _error} = ChatgptPrompts.add_chatgpt_prompt("invalid", "test")
    end

    test "fails to add an duplicate chatgpt_prompt", %{channel: channel} do
      assert {:ok, _prompt1} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert {:error, _prompt2} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
    end
  end

  describe "get_chatgpt_prompt/2" do
    test "gets a chatgpt_prompt", %{channel: channel} do
      assert {:ok, prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert prompt.message == "test"
    end

    test "fails to get a chatgpt_prompt with invalid message", %{channel: channel} do
      assert {:error, _error} = ChatgptPrompts.get_chatgpt_prompt(channel.channel_id, "invalid")
    end
  end

  describe "delete_chatgpt_prompt/2" do
    test "deletes a chatgpt_prompt", %{channel: channel} do
      assert {:ok, _prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert {:ok, _prompt} = ChatgptPrompts.delete_chatgpt_prompt(channel.channel_id, "test")
    end

    test "fails to delete a chatgpt_prompt with invalid message", %{channel: channel} do
      assert {:error, _error} = ChatgptPrompts.delete_chatgpt_prompt(channel.channel_id, "invalid")
    end
  end

  describe "list_chatgpt_prompts/1" do
    test "lists chatgpt_prompts", %{channel: channel} do
      assert {:ok, _prompt1} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test1")
      assert {:ok, _prompt2} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test2")
      assert {:ok, _prompt3} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test3")

      assert {:ok, prompts} = ChatgptPrompts.list_chatgpt_prompts(channel.channel_id)
      assert length(prompts) == 3
    end

    test "fails to list chatgpt_prompts with invalid channel_id" do
      assert {:error, _error} = ChatgptPrompts.list_chatgpt_prompts("invalid")
    end
  end

  describe "add_chatgpt_prompt_history/2" do
    test "adds a new chatgpt_prompt_history", %{channel: channel} do
      assert {:ok, prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert {:ok, history} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "a reply to test")
      assert history.content == "a reply to test"
      assert history.gpt_prompt_id == prompt.id
    end

    test "adds a new chatgpt_prompt_history with empty content", %{channel: channel} do
      assert {:ok, prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert {:error, _history} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "")
    end
  end

  describe "get_chatgpt_prompt_history/1" do
    test "gets a chatgpt_prompt_history", %{channel: channel} do
      assert {:ok, prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert {:ok, history} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "a reply to test")
      assert {:ok, history_get} = ChatgptPrompts.get_chatgpt_prompt_history(history.id)
      assert history_get.id == history.id
    end

    test "fails to get a chatgpt_prompt_history with invalid content" do
      assert {:error, _error} = ChatgptPrompts.get_chatgpt_prompt_history(123456)
    end
  end

  describe "delete_chatgpt_prompt_history/1" do
    test "deletes a chatgpt_prompt_history", %{channel: channel} do
      assert {:ok, prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert {:ok, history} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "a reply to test")
      assert {:ok, _history} = ChatgptPrompts.delete_chatgpt_prompt_history(history.id)
    end

    test "fails to delete a chatgpt_prompt_history with invalid content" do
      assert {:error, _error} = ChatgptPrompts.delete_chatgpt_prompt_history(123456)
    end
  end

  describe "list_chatgpt_prompt_histories/1" do
    test "lists chatgpt_prompt_histories", %{channel: channel} do
      assert {:ok, prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert {:ok, _history1} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "a reply to test")
      assert {:ok, _history2} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "another reply to test")
      assert {:ok, _history3} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "yet another reply to test")

      assert {:ok, histories} = ChatgptPrompts.list_chatgpt_prompt_histories(prompt.id)
      assert length(histories) == 3
    end
  end

  describe "truncate_chatgpt_prompt_histories/1" do
    test "truncates chatgpt_prompt_histories", %{channel: channel} do
      assert {:ok, prompt} = ChatgptPrompts.add_chatgpt_prompt(channel.channel_id, "test")
      assert {:ok, _history1} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "a reply to test")
      assert {:ok, _history2} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "another reply to test")
      assert {:ok, _history3} = ChatgptPrompts.add_chatgpt_prompt_history(prompt.id, "yet another reply to test")

      assert {:ok, _} = ChatgptPrompts.truncate_chatgpt_prompt_histories(prompt.id, 2)
      assert {:ok, histories} = ChatgptPrompts.list_chatgpt_prompt_histories(prompt.id)
      assert length(histories) == 2
    end
  end
end
