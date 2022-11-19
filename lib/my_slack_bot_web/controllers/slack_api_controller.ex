defmodule MySlackBotWeb.SlackApiController do
  use MySlackBotWeb, :controller

  require Logger

  alias MySlackBot.SlackApi.SlackBot
  alias MySlackBot.SlackApi.SlackCommand

  def command(
        conn,
        %{
          "command" => "/list",
          "channel_id" => channel_id,
          "channel_name" => channel_name,
        } = params
      ) do
    Logger.info("params: #{inspect(params)}")

    {:ok, names} =
      SlackBot.add_channel_if_not_exists(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> SlackCommand.process_list_members_command()

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
    Logger.info("params: #{inspect(params)}")

    {_, status} =
      SlackBot.add_channel_if_not_exists(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> SlackCommand.process_add_member_command(text)

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
    Logger.info("params: #{inspect(params)}")

    {_, status} =
      SlackBot.add_channel_if_not_exists(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> SlackCommand.process_delete_member_command(text)

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
    Logger.info("params: #{inspect(params)}")

    message =
      case String.trim(text) do
        "" ->
          "you have been picked to run the standup!"
        _ -> text
      end

    {_, status} =
      SlackBot.add_channel_if_not_exists(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> SlackCommand.process_pick_member_command(message)

    render(conn, "pick.json", %{status: status})
  end

  def command(
        conn,
        %{
          "command" => "/list-tasks",
          "channel_id" => channel_id,
          "channel_name" => channel_name,
        } = params
      ) do
    Logger.info("params: #{inspect(params)}")

    {:ok, tasks} =
      SlackBot.add_channel_if_not_exists(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> SlackCommand.process_list_tasks_command()

    render(conn, "list-tasks.json", %{tasks: tasks})
  end

  def command(
        conn,
        %{
          "command" => "/add-task",
          "channel_id" => channel_id,
          "channel_name" => channel_name,
          "text" => text,
        } = params
      ) do
    Logger.info("params: #{inspect(params)}")

    {_, status} =
      SlackBot.add_channel_if_not_exists(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> SlackCommand.process_add_task_command(text)

    render(conn, "add-task.json", %{status: status})
  end

  def command(
        conn,
        %{
          "command" => "/delete-task",
          "channel_id" => channel_id,
          "channel_name" => channel_name,
          "text" => text,
        } = params
      ) do
    Logger.info("params: #{inspect(params)}")

    {_, status} =
      SlackBot.add_channel_if_not_exists(channel_id, channel_name)
      |> Map.get(:channel_id)
      |> SlackCommand.process_delete_task_command(text)

    render(conn, "delete-task.json", %{status: status})
  end

  def command(conn, data) do
    Logger.info("data: #{inspect(data)}")
    render(conn, "slack_commands.json", %{data: data})
  end
end
