defmodule MySlackBot.Repo do
  use Ecto.Repo,
    otp_app: :my_slack_bot,
    adapter: Ecto.Adapters.Postgres
end
