defmodule MySlackBot.SlackApi.SlackBot do
  import Ecto.Query, warn: false

  require Logger

  alias MySlackBot.Repo
  alias MySlackBot.Models.SlackChannel
  alias MySlackBot.Models.SlackMember
  alias MySlackBot.Models.SlackTask

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

  def add_channel_if_not_exists(channel_id, channel_name) do
    get_channel(channel_id)
    |> case do
      {:ok, channel} ->
       channel

      {:error, _} ->
        {:ok, channel} = add_channel(channel_id, channel_name)
        channel
    end
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
    with {:ok, channel} <- get_channel(channel_id) do
      %SlackMember{}
      |> SlackMember.changeset(%{name: name, slack_channel_id: channel.id})
      |> Repo.insert()
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_member(channel_id, name) do
    with {:ok, channel} <- get_channel(channel_id) do
      SlackMember
      |> where([m], m.name == ^name and m.slack_channel_id == ^channel.id)
      |> Repo.one()
      |> case do
        nil -> {:error, "name: #{name} not found"}
        member -> {:ok, member}
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  def delete_member(channel_id, name) do
    with {:ok, channel} <- get_channel(channel_id) do
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
    else
      {:error, error} -> {:error, error}
    end
  end

  def list_members(channel_id) do
    with {:ok, channel} <- get_channel(channel_id) do
      members =
        SlackMember
        |> where([m], m.slack_channel_id == ^channel.id)
        |> Repo.all()

      {:ok, members}
    else
      {:error, error} -> {:error, error}
    end
  end

  def list_tasks(channel_id) do
    with {:ok, channel} <- get_channel(channel_id) do
      tasks =
        SlackTask
        |> where([t], t.slack_channel_id == ^channel.id)
        |> preload([t], :slack_channel)
        |> Repo.all()

      {:ok, tasks}
    else
      {:error, error} -> {:error, error}
    end
  end

  def list_active_tasks(day, hour, minute) do
    day_in_string = to_string(day)
    tasks =
      SlackTask
      |> where([t], fragment("days->? = 'true'", ^day_in_string))
      |> where([t], t.hour == ^hour)
      |> where([t], t.minute == ^minute)
      |> where([t], t.status == :active)
      |> preload([t], :slack_channel)
      |> Repo.all()

    {:ok, tasks}
  end

  def add_task(channel_id, name, days, hour, minute, status, command, command_argument) do
    with {:ok, channel} <- get_channel(channel_id) do
      %SlackTask{}
      |> SlackTask.changeset(%{
        slack_channel_id: channel.id,
        name: name,
        days: days,
        hour: hour,
        minute: minute,
        status: status,
        command: command,
        command_argument: command_argument
      })
      |> Repo.insert()
    else
      {:error, error} -> {:error, error}
    end
  end

  def delete_task(channel_id, name) do
    with {:ok, channel} <- get_channel(channel_id) do
      SlackTask
      |> where([t], t.name == ^name and t.slack_channel_id == ^channel.id)
      |> Repo.one()
      |> case do
        nil ->
          {:error, "task with name: #{name} not found"}

        task ->
          Repo.delete(task)
          {:ok, task}
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_task(channel_id, name) do
    with {:ok, channel} <- get_channel(channel_id) do
      SlackTask
      |> where([t], t.name == ^name and t.slack_channel_id == ^channel.id)
      |> Repo.one()
      |> case do
        nil -> {:error, "task with name: #{name} not found"}
        task -> {:ok, task}
      end
    else
      {:error, error} -> {:error, error}
    end
  end
end
