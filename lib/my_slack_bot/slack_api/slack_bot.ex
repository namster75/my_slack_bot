defmodule MySlackBot.SlackApi.SlackBot do
  import Ecto.Query, warn: false

  require Logger

  alias MySlackBot.Repo
  alias MySlackBot.Models.SlackChannel
  alias MySlackBot.Models.SlackMember

  def list_channels(nil) do
    {:error, "channel_id is nil"}
  end

  def list_channels("") do
    {:error, "channel_id is empty"}
  end

  def list_channels(channel_id) do
    channels =
      SlackChannel
      |> where([c], c.channel_id == ^channel_id)
      |> Repo.all()

    {:ok, channels}
  end

  def add_channel(channel_id, channel_name) do
    %SlackChannel{}
    |> SlackChannel.changeset(%{channel_id: channel_id, channel_name: channel_name})
    |> Repo.insert()
  end

  def get_channel(channel_id) do
    SlackChannel
    |> where([c], c.channel_id == ^channel_id)
    |> Repo.one()
    |> case do
      nil -> {:error, "channel_id: #{channel_id} not found"}
      channel -> {:ok, channel}
    end
  end

  def delete_channel(channel_id) do
    SlackChannel
    |> where([c], c.channel_id == ^channel_id)
    |> Repo.one()
    |> case do
      nil ->
        {:error, "channel_id: #{channel_id} not found"}

      channel ->
        Repo.delete(channel)
        {:ok, channel}
    end
  end

  def add_member(channel_id, name) do
    {:ok, channel} = get_channel(channel_id)
    %SlackMember{}
    |> SlackMember.changeset(%{name: name, slack_channel_id: channel.id})
    |> Repo.insert()
  end

  def get_member(channel_id, name) do
    {:ok, channel} = get_channel(channel_id)
    SlackMember
    |> where([m], m.name == ^name and m.slack_channel_id == ^channel.id)
    |> Repo.one()
    |> case do
      nil -> {:error, "name: #{name} not found"}
      member -> {:ok, member}
    end
  end

  def delete_member(channel_id, name) do
    {:ok, channel} = get_channel(channel_id)
    SlackMember
    |> where([m], m.name == ^name and m.slack_channel_id == ^channel.id)
    |> Repo.one()
    |> case do
      nil ->
        {:error, "name: #{name} not found"}

      member ->
        Repo.delete(member)
        {:ok, member}
    end
  end

  def list_members(channel_id) do
    {:ok, channel} = get_channel(channel_id)
    members =
      SlackMember
      |> where([m], m.slack_channel_id == ^channel.id)
      |> Repo.all()

    {:ok, members}
  end
end
