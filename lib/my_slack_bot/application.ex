defmodule MySlackBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias  MySlackBot.SlackApi.SlackTaskServer
  alias  MySlackBot.SlackApi.SlackUserServer

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MySlackBot.Repo,
      # Start the Telemetry supervisor
      MySlackBotWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MySlackBot.PubSub},
      # Start the Endpoint (http/https)
      MySlackBotWeb.Endpoint,
      # Start a worker by calling: MySlackBot.Worker.start_link(arg)
      {SlackTaskServer, %{}},
      {SlackUserServer, %{}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MySlackBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MySlackBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
