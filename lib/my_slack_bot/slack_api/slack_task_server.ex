defmodule MySlackBot.SlackApi.SlackTaskServer do
  use GenServer

  require Logger

  alias MySlackBot.SlackApi.SlackBot
  alias MySlackBot.SlackApi.SlackCommand

  # Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # Server
  def init(opts) do
    Logger.info("SlackTaskServer init: #{inspect(opts)}")
    Process.send_after(self(), :process_tasks, get_milliseconds_until_next_minute())
    {:ok, opts}
  end

  def handle_info(:process_tasks, state) do
    now = DateTime.now!("America/Los_Angeles")
    Logger.info("day: #{now.day}, hour: #{now.hour}, minute: #{now.minute}")
    day_of_week = now |> DateTime.to_date() |> Date.day_of_week()
    with {:ok, tasks} <- SlackBot.list_active_tasks(get_day_as_atom(day_of_week), now.hour, now.minute) do
      tasks
      |> Enum.each(fn task ->
        Logger.info("task: #{inspect(task)}")
        case task.command do
          :pick ->
            {:ok, reply} =
              SlackCommand.process_pick_member_command(
                task.slack_channel.channel_id, task.command_argument)
            Logger.info("process command with reply: #{reply}")
          :generate_random_prompt ->
              {:ok, reply} =
                SlackCommand.process_generate_random_prompt_command(
                  task.slack_channel.channel_id)
              Logger.info("process command with reply: #{reply}")
          _ ->
            Logger.error("#{task.command} command is not supported")
        end
      end)
    else
      {:error, reason} ->
        Logger.error("SlackTaskServer handle_info: :process_tasks, reason: #{inspect(reason)}")
    end

    Process.send_after(self(), :process_tasks, get_milliseconds_until_next_minute())
    {:noreply, state}
  end

  defp get_milliseconds_until_next_minute do
    %DateTime{second: second} = DateTime.now!("America/Los_Angeles")
    (60 - second + 1) * 1000
  end

  defp get_day_as_atom(day) do
    case day do
      1 -> :monday
      2 -> :tuesday
      3 -> :wednesday
      4 -> :thursday
      5 -> :friday
      6 -> :saturday
      7 -> :sunday
    end
  end
end
