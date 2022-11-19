defmodule MySlackBot.Repo.Migrations.CreateSlackTasks do
  use Ecto.Migration

  def change do
    create table(:slack_tasks) do
      add :name, :string, null: false, required: true
      add :days, :map, null: false, required: true
      add :hour, :integer, null: false, required: true
      add :minute, :integer, null: false, required: true
      add :status, :string, null: false, required: true
      add :slack_channel_id, references(:slack_channels, on_delete: :nothing), null: false, required: true
      add :command, :string, null: false, required: true
      add :command_argument, :string

      timestamps()
    end

    create index(:slack_tasks, [:slack_channel_id])
    create unique_index(:slack_tasks, [:name, :slack_channel_id])
  end
end
