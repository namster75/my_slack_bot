defmodule MySlackBotWeb.SlackApiController do
  use MySlackBotWeb, :controller

  require Logger

  alias MySlackBot.SlackApi.SlackClient
  alias MySlackBot.SlackApi.SlackBot

  def command(
        conn,
        %{
          "command" => "/list",
          "channel_id" => channel_id,
          "channel_name" => channel_name,
        } = params
      ) do
    Logger.info("command: data: #{inspect(params)}")

    names =
      add_channel(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> SlackBot.list_members()
      |> case do
        {:ok, members} -> members |> Enum.map(fn member -> member.name end)
      end

    render(conn, "list.json", %{names: names})
  end

  def command(
        conn,
        %{
          "command" => "/add",
          "channel_id" => channel_id,
          "channel_name" => channel_name,
          "text" => text,
        } = params
      ) do
    Logger.info("command: data: #{inspect(params)}")

    status =
      add_channel(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> add_member(text)

    render(conn, "add.json", %{status: status})
  end

  def command(
        conn,
        %{
          "command" => "/delete",
          "channel_id" => channel_id,
          "channel_name" => channel_name,
          "text" => text,
        } = params
      ) do
    Logger.info("command: data: #{inspect(params)}")

    status =
      add_channel(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> delete_member(text)

    render(conn, "delete.json", %{status: status})
  end

  def command(
        conn,
        %{
          "command" => "/pick",
          "channel_id" => channel_id,
          "channel_name" => channel_name,
          "text" => text,
        } = params
      ) do
    Logger.info("command: data: #{inspect(params)}")

    message =
      case String.trim(text) do
        "" ->
          "you have been picked to run the standup!"
        _ -> text
      end

    status =
      add_channel(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> pick_member(message)

    render(conn, "pick.json", %{status: status})
  end

  def command(conn, data) do
    Logger.info("command: data: #{inspect(data)}")
    render(conn, "slack_commands.txt", %{data: data})
  end

  defp add_channel(channel_id, channel_name) do
    SlackBot.get_channel(channel_id)
    |> case do
      {:ok, channel} ->
       channel

      {:error, _} ->
        {:ok, channel} = SlackBot.add_channel(channel_id, channel_name)
        channel
    end
  end

  defp add_member(_channel_id, nil) do
    "name must be provided"
  end

  defp add_member(_channel_id, "") do
    "name must be provided"
  end

  defp add_member(channel_id, name) do
    SlackBot.add_member(channel_id, name)
    |> case do
      {:ok, member} ->
       "member: #{member.name} has been added"

      {:error, error} ->
        "failed to add member: #{name} => #{inspect(error)}"
    end
  end

  defp delete_member(channel_id, name) do
    SlackBot.delete_member(channel_id, name)
    |> case do
      {:ok, member} ->
       "member: #{member.name} has been deleted"

      {:error, error} ->
        "failed to delete member: #{name} => #{inspect(error)}"
    end
  end

  defp pick_member(channel_id, message) do
    SlackBot.list_members(channel_id)
    |> case do
      {:ok, []} ->
       "no members to pick"

      {:ok, members} ->
        reply = Enum.random(members) |> then(&"#{&1.name}, #{message}")
        SlackClient.send_message(channel_id, reply)
        reply
    end
  end
end
