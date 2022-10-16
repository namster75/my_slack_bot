defmodule MySlackBot.Repo.Migrations.CreateSlackMembers do
  use Ecto.Migration

  def change do
    create table(:slack_members) do
      add :name, :string, null: false, required: true
      add :slack_channel_id, references(:slack_channels, on_delete: :nothing)

      timestamps()
    end

    create index(:slack_members, [:slack_channel_id])
    create unique_index(:slack_members, [:name, :slack_channel_id])
  end
end
