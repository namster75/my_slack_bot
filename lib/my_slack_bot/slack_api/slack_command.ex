defmodule MySlackBot.SlackApi.SlackCommand do

  require Logger

  alias MySlackBot.ChatgptPrompts
  alias MySlackBot.SlackApi.SlackBot
  alias MySlackBot.SlackApi.SlackUserServer

  @slack_client Application.compile_env!(:my_slack_bot, :slack_client_module)
  @chatgpt_client Application.compile_env!(:my_slack_bot, :chatgpt_client_module)

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
        shuffled_names =
          members
          |> Enum.map(fn member -> member.name end)
          |> Enum.shuffle()

        reply =
          shuffled_names
          |> Enum.random()
          |> format_member_mention_name()
          |> then(&"#{&1}, #{message}")

        full_reply =
          "`[#{Enum.join(shuffled_names, ", ")}] |> Enum.random()` => #{reply}"

        @slack_client.send_message(channel_id, full_reply)
        {:ok, full_reply}
    end
  end

  defp format_member_mention_name(member_name) do
    case SlackUserServer.get_user_by_display_name(member_name) do
      nil -> member_name
      user_id -> "<@#{user_id}>"
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
            ""
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

  def process_add_prompt_command(_channel_id, nil) do
    {:error, "message cannot be nil"}
  end

  def process_add_prompt_command(_channel_id, "") do
    {:error, "message cannot be empty"}
  end

  def process_add_prompt_command(channel_id, message) do
    ChatgptPrompts.add_chatgpt_prompt(channel_id, message)
    |> case do
      {:ok, prompt} ->
       {:ok, "prompt: #{prompt.message} has been added"}

      {:error, error} ->
        {:error, "failed to add prompt: #{message} => #{inspect(error)}"}
    end
  end

  def process_delete_prompt_command(channel_id, message) do
    ChatgptPrompts.delete_chatgpt_prompt(channel_id, message)
    |> case do
      {:ok, prompt} ->
       {:ok, "prompt: #{prompt.message} has been deleted"}

      {:error, error} ->
        {:error, "failed to delete member: #{message} => #{inspect(error)}"}
    end
  end

  def process_list_prompts_command(channel_id) do
    messages =
      channel_id
      |> ChatgptPrompts.list_chatgpt_prompts()
      |> case do
        {:ok, prompts} -> prompts |> Enum.map(fn prompt -> prompt.message end)
      end

    {:ok, messages}
  end

  def process_generate_random_prompt_command(channel_id) do
    ChatgptPrompts.list_chatgpt_prompts(channel_id)
    |> case do
      {:ok, []} ->
       {:ok, "no prompt to pick"}

      {:ok, prompts} ->
        random_prompt =
          prompts
          |> Enum.shuffle()
          |> Enum.random()

        message_response =
          create_chatgpt_prompt_message(random_prompt)
          |> case do
            {:ok, response} ->
              ChatgptPrompts.add_chatgpt_prompt_history(random_prompt.id, response)
              ChatgptPrompts.truncate_chatgpt_prompt_histories(random_prompt.id, 10)
              response

            {:error, error} ->
              Logger.error(error)
              "failed to create_chat_completion"
          end

        full_reply =
          "*#{random_prompt.message}*\n ```#{message_response}```"

        @slack_client.send_message(channel_id, full_reply)
        {:ok, full_reply}

      {:error, error} ->
        {:error, "failed to list prompts: #{channel_id} => #{inspect(error)}"}
    end
  end

  defp create_chatgpt_prompt_message(prompt) do
    build_chatgpt_prompt_input_message(prompt)
    |> @chatgpt_client.create_chat_completion()
    |> case do
      {:ok, %{"choices" => [%{"message" => %{"content" => content}}]}} ->
       {:ok, content}

      {:error, error} ->
        {:error, "failed to create_chat_completion: #{prompt.message} => #{inspect(error)}"}
    end
  end

  defp build_chatgpt_prompt_input_message(prompt) do
    [%{"role" => "system", "content" => "You are a helpful assistant."}]
    |> Enum.concat(build_chatgpt_prompt_input_message_from_history(prompt, 5))
    |> Enum.concat(
      [%{"role" => "user", "content" => "another #{prompt.message}"}]
    )
  end

  defp build_chatgpt_prompt_input_message_from_history(prompt, max_history_count) do
    prompt.id
    |> ChatgptPrompts.list_chatgpt_prompt_histories()
    |> then(fn {:ok, histories} ->
      histories
      |> Enum.take(max_history_count)
      |> Enum.map(fn history ->
        [
          %{"role" => "user", "content" => "another #{prompt.message}"},
          %{"role" => "assistant", "content" => history.content}
        ]
      end)
      |> List.flatten()
    end)
  end
end
