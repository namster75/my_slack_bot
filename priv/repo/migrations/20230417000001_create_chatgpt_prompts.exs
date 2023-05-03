defmodule MySlackBot.Repo.Migrations.CreateChatgptPrompts do
  use Ecto.Migration

  def change do
    create table(:gpt_prompts) do
      add :message, :string, null: false, required: true
      add :slack_channel_id, references(:slack_channels, on_delete: :delete_all)

      timestamps()
    end

    create index(:gpt_prompts, [:slack_channel_id])
    create unique_index(:gpt_prompts, [:message, :slack_channel_id])
  end
end
