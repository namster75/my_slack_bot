defmodule MySlackBot.SlackApi.SlackCommand do
  alias MySlackBot.SlackApi.SlackBot

  @slack_client Application.compile_env!(:my_slack_bot, :slack_client_module)

  def process_list_members_command(channel_id) do
    names =
      channel_id
      |> SlackBot.list_members()
      |> case do
        {:ok, members} -> members |> Enum.map(fn member -> member.name end)
      end

    {:ok, names}
  end

  def process_add_member_command(_channel_id, nil) do
    {:error, "name cannot be nil"}
  end

  def process_add_member_command(_channel_id, "") do
    {:error, "name cannot be empty"}
  end

  def process_add_member_command(channel_id, name) do
    SlackBot.add_member(channel_id, name)
    |> case do
      {:ok, member} ->
       {:ok, "member: #{member.name} has been added"}

      {:error, error} ->
        {:error, "failed to add member: #{name} => #{inspect(error)}"}
    end
  end

  def process_delete_member_command(channel_id, name) do
    SlackBot.delete_member(channel_id, name)
    |> case do
      {:ok, member} ->
       {:ok, "member: #{member.name} has been deleted"}

      {:error, error} ->
        {:error, "failed to delete member: #{name} => #{inspect(error)}"}
    end
  end

  def process_pick_member_command(channel_id, message) do
    SlackBot.list_members(channel_id)
    |> case do
      {:ok, []} ->
       {:ok, "no members to pick"}

      {:ok, members} ->
        reply = Enum.random(members) |> then(&"#{&1.name}, #{message}")
        @slack_client.send_message(channel_id, reply)
        {:ok, reply}
    end
  end

  # defdoc """
  # --name <task-name> i.e. --name "My Task"
  # --day <day-of-week> i.e. --day Monday or --day Tuesday ...
  # --hour <hour-of-day> i.e --hour 10
  # --minute <minute-of-hour> i.e --minute 30
  # --status <status> i.e. --status paused or --status active
  # --command <command> i.e --command pick
  # --command_args <command_args> i.e --command_args ", you are picked to run standup!"
  # """
  def parse_add_task_command_args(arguments) do
    try do
      {args, _} =
        OptionParser.split(arguments)
        |> OptionParser.parse!([
          strict: [
            name: :string,
            day: :keep,
            hour: :integer,
            minute: :integer,
            status: :string,
            command: :string,
            command_args: :string
          ]
        ])

      task_name =
        case Enum.find_value(args, fn {key, value} -> if key == :name, do: value end) do
          nil ->
            raise "--name is required"
          name -> name
        end

      task_days =
        args
        |> Enum.filter(fn {key, _value} -> key == :day end)
        |> Enum.map(fn {_key, value} -> value end)
        |> case do
          [] ->
            raise "--day is required"
          days ->
            Enum.reduce(days, %{}, fn day, acc ->
              case String.upcase(day) do
                "MONDAY" -> Map.put(acc, :monday, true)
                "TUESDAY" -> Map.put(acc, :tuesday, true)
                "WEDNESDAY" -> Map.put(acc, :wednesday, true)
                "THURSDAY" -> Map.put(acc, :thursday, true)
                "FRIDAY" -> Map.put(acc, :friday, true)
                "SATURDAY" -> Map.put(acc, :saturday, true)
                "SUNDAY" -> Map.put(acc, :sunday, true)
                _ -> raise "invalid day: #{day}"
              end
            end)
        end

      task_hour =
        case Enum.find_value(args, fn {key, value} -> if key == :hour, do: value end) do
          nil ->
            raise "--hour is required"
          hour -> hour
        end

      task_minute =
        case Enum.find_value(args, fn {key, value} -> if key == :minute, do: value end) do
          nil ->
            raise "--minute is required"
          minute -> minute
        end

      task_status =
          case Enum.find_value(args, fn {key, value} -> if key == :status, do: value end) do
            nil -> :active
            status -> String.to_atom(status)
          end

      task_command =
        case Enum.find_value(args, fn {key, value} -> if key == :command, do: value end) do
          nil ->
            raise "--command is required"
          command -> String.to_atom(command)
        end

      task_command_argument =
        case Enum.find_value(args, fn {key, value} -> if key == :command_args, do: value end) do
          nil ->
            raise "--command-args is required"
          command_args -> command_args
        end

      {:ok,
      %{
        name: task_name,
        days: task_days,
        hour: task_hour,
        minute: task_minute,
        status: task_status,
        command: task_command,
        command_argument: task_command_argument
      }}
    rescue
      e in OptionParser.ParseError ->
        {:error, e.message}
      error ->
        {:error, error}
    end
  end

  def process_list_tasks_command(channel_id) do
    task_info_list =
      channel_id
      |> SlackBot.list_tasks()
      |> case do
        {:ok, tasks} ->
          tasks
          |> Enum.map(fn task ->
            days =
              task.days
              |> Map.from_struct()
              |> Map.to_list()
              |> Enum.filter(fn {_day, value} -> value end)
              |> Enum.map(fn {day, _value} -> String.slice(to_string(day), 0..2) end)
              |> Enum.join("/")
            "#{task.name} #{days} #{task.hour}:#{task.minute} => /#{task.command} #{task.command_argument}"
          end)
      end

    {:ok, task_info_list}
  end

  def process_add_task_command(channel_id, arguments) do
    with {:ok,
          %{
            name: name,
            days: days,
            hour: hour,
            minute: minute,
            status: status,
            command: command,
            command_argument: command_argument}} <- parse_add_task_command_args(arguments),
         {:ok, task} <- SlackBot.add_task(channel_id, name, days, hour, minute, status, command, command_argument) do
      {:ok, "task: #{task.name} has been added"}
    else
      {:error, error} ->
        {:error, "failed to add task: #{arguments} => #{inspect(error)}"}
    end
  end

  def process_delete_task_command(channel_id, name) do
    SlackBot.delete_task(channel_id, name)
    |> case do
      {:ok, task} ->
       {:ok, "task: #{task.name} has been deleted"}

      {:error, error} ->
        {:error, "failed to delete task: #{name} => #{inspect(error)}"}
    end
  end

end
