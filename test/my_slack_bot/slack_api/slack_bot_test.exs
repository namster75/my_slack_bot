defmodule MySlackBot.SlackApi.SlackBotTest do
  use MySlackBot.DataCase

  alias MySlackBot.Repo
  alias MySlackBot.Models.SlackChannel
  alias MySlackBot.Models.SlackMember
  alias MySlackBot.SlackApi.SlackBot

  describe "list_channels/1" do
    test "returns :error when channel_id is nil" do
      assert {:error, _} = SlackBot.list_channels(nil)
    end

    test "returns :error when channel_id is empty" do
      assert {:error, _} = SlackBot.list_channels("")
    end

    test "returns :ok when channel_id is valid" do
      assert {:ok, []} = SlackBot.list_channels("C01")
    end
  end

  describe "add_channel/2" do
    test "returns :ok when channel_id and channel_name are valid" do
      assert {:ok, %{channel_id: "C01", channel_name: "general"}} = SlackBot.add_channel("C01", "general")
    end

    test "returns :error when channel_id is nil" do
      assert {:error, _} = SlackBot.add_channel(nil, "general")
    end

    test "returns :error when channel_id is empty" do
      assert {:error, _} = SlackBot.add_channel("", "general")
    end

    test "returns :error when channel_name is nil" do
      assert {:error, _} = SlackBot.add_channel("C01", nil)
    end

    test "returns :error when channel_name is empty" do
      assert {:error, _} = SlackBot.add_channel("C01", "")
    end
  end

  describe "get_channel/1" do
    test "returns :error when channel_id is not found" do
      assert {:error, _} = SlackBot.get_channel("C01")
    end

    test "returns :ok when channel_id is found" do
      {:ok, %{channel_id: "C01", channel_name: "general"}} = SlackBot.add_channel("C01", "general")
      assert {:ok, %{channel_id: "C01", channel_name: "general"}} = SlackBot.get_channel("C01")
    end
  end

  describe "delete_channel/1" do
    test "returns :error when channel_id is not found" do
      assert {:error, _} = SlackBot.delete_channel("C01")
    end

    test "returns :ok when channel_id is found" do
      {:ok, %{channel_id: "C01", channel_name: "general"}} = SlackBot.add_channel("C01", "general")
      assert {:ok, %{channel_id: "C01", channel_name: "general"}} = SlackBot.delete_channel("C01")
    end
  end

  describe "add_member/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "general")

      {:ok, channel: channel}
    end

    test "returns :ok when channel_id and name are valid", %{channel: channel} do
      assert {:ok, %{name: "John Doe"}} = SlackBot.add_member(channel.channel_id, "John Doe")
    end

    test "returns :error when name is nil", %{channel: channel} do
      assert {:error, _} = SlackBot.add_member(channel.channel_id, nil)
    end

    test "returns :error when name is empty", %{channel: channel} do
      assert {:error, _} = SlackBot.add_member(channel.channel_id, "")
    end
  end

  describe "get_member/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "general")
      {:ok, member} = SlackBot.add_member(channel.channel_id, "John Doe")

      {:ok, channel: channel, member: member}
    end

    test "returns :error when name is not found", %{channel: channel} do
      assert {:error, _} = SlackBot.get_member(channel.channel_id, "Jane Doe")
    end

    test "returns :ok when channel_id and name are found", %{channel: channel, member: member} do
      assert {:ok, %{name: "John Doe"}} = SlackBot.get_member(channel.channel_id, member.name)
    end
  end

  describe "delete_member/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "general")
      {:ok, member} = SlackBot.add_member(channel.channel_id, "John Doe")

      {:ok, channel: channel, member: member}
    end

    test "returns :error when name is not found", %{channel: channel} do
      assert {:error, _} = SlackBot.delete_member(channel.channel_id, "Jane Doe")
    end

    test "returns :ok when channel_id and name are found", %{channel: channel, member: member} do
      assert {:ok, %{name: "John Doe"}} = SlackBot.delete_member(channel.channel_id, member.name)
    end
  end

  describe "list_members/1" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "general")
      {:ok, member} = SlackBot.add_member(channel.channel_id, "John Doe")

      {:ok, channel: channel, member: member}
    end

    test "returns :ok when channel_id is valid", %{channel: channel} do
      assert {:ok, [member]} = SlackBot.list_members(channel.channel_id)
    end
  end
end
