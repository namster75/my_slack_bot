defmodule MySlackBot.Repo.Migrations.CreateSlackChannels do
  use Ecto.Migration

  def change do
    create table(:slack_channels) do
      add :channel_id, :string, null: false, required: true
      add :channel_name, :string, null: false, required: true

      timestamps()
    end

    # create unique_index(:slack_channels, [:channel_id])
    # create unique_index(:slack_channels, [:channel_name])
  end
end
