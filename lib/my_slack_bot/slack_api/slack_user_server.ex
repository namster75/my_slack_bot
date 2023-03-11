defmodule MySlackBot.SlackApi.SlackUserServer do
  use GenServer

  require Logger

  @slack_client Application.compile_env!(:my_slack_bot, :slack_client_module)

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # API

  def get_user_by_display_name(name) do
    GenServer.call(__MODULE__, {:get_user_by_display_name, name})
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  # Server
  def init(state) do
    Logger.info("SlackUserServer init: #{inspect(state)}")
    Process.send_after(self(), :refresh_users, 60_000) # 1 minute
    {:ok, state}
  end

  def handle_call({:get_user_by_display_name, name}, _from, state) do
    case Map.get(state, :users) do
      nil ->
        {:reply, nil, state}
      users ->
        {:reply, Map.get(users, name), state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh_users, state) do
    with {:ok, users} <- @slack_client.list_users(),
      {:ok, sanitized_users} <- validate_and_sanitize_users(users) do
      Logger.info("SlackUserServer handle_info: :refresh_users #{Map.keys(sanitized_users) |> Enum.count()} users")
      state = Map.put(state, :users, sanitized_users)
      Process.send_after(self(), :refresh_users, 86_400_000) # 24 hours
      {:noreply, state}
    else
      {:error, reason} ->
        Logger.error("SlackUserServer handle_info: :refresh_users, reason: #{inspect(reason)}")
        Process.send_after(self(), :refresh_users, 86_400_000) # 24 hours
        {:noreply, state}
    end
  end

  defp validate_and_sanitize_users(%{"ok" => false, "error" => error} = _users) do
    {:error, "Slack API returned error #{error}"}
  end

  defp validate_and_sanitize_users(%{"ok" => true, "members" => members} = _users) do
    members
    |> Enum.filter(fn member -> member["deleted"] == false end)
    |> Enum.filter(fn member -> !is_nil(member["id"]) end)
    |> Enum.filter(fn member -> get_in(member, ["profile", "display_name"]) not in [nil, ""] end)
    |> Enum.map(fn member ->
      %{
        id: member["id"],
        display_name: member["profile"]["display_name"]
      }
    end)
    |> Enum.reduce(%{}, fn user, acc ->
      Map.put(acc, user.display_name, user.id)
    end)
    |> then(fn users -> {:ok, users} end)
  end
end
