defmodule MySlackBotWeb.SlackApiView do
  use MySlackBotWeb, :view

  def render("list.json", %{names: names}) do
    case Enum.empty?(names) do
      true -> "[No members]"
      false -> names |> Enum.join(", ")
    end
  end

  def render("add.json", %{status: status}) do
    status
  end

  def render("delete.json", %{status: status}) do
    status
  end

  def render("pick.json", %{status: status}) do
    status
  end

  def render("list-tasks.json", %{tasks: tasks}) do
    case Enum.empty?(tasks) do
      true -> "[No tasks]"
      false ->
        tasks
        |> Enum.with_index(fn task, index ->
          "#{index + 1}. #{task}"
        end)
        |> Enum.join(" | ")
    end
  end

  def render("add-task.json", %{status: status}) do
    status
  end

  def render("delete-task.json", %{status: status}) do
    status
  end

  def render("list-prompts.json", %{prompts: prompts}) do
    case Enum.empty?(prompts) do
      true -> "[No prompt]"
      false ->
        prompts
        |> Enum.with_index(fn prompt, index ->
          "#{index + 1}. #{prompt}"
        end)
        |> Enum.join(" | ")
    end
  end

  def render("add-prompt.json", %{status: status}) do
    status
  end

  def render("delete-prompt.json", %{status: status}) do
    status
  end

  def render("generate-random-prompt.json", %{status: status}) do
    status
  end

  def render("slack_commands.json", %{data: data}) do
    "Unhandled command #{inspect(data)}"
  end
end
