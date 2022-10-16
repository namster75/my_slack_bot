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

  def render("slack_commands.json", %{data: data}) do
    "Unhandeled command #{inspect(data)}"
  end
end
