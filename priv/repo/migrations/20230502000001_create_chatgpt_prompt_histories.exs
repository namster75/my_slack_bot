defmodule MySlackBot.Repo.Migrations.CreateChatgptPromptHistories do
  use Ecto.Migration

  def change do
    create table(:gpt_prompt_histories) do
      add :content, :text, null: false, required: true
      add :gpt_prompt_id, references(:gpt_prompts, on_delete: :delete_all)

      timestamps()
    end

    create index(:gpt_prompt_histories, [:gpt_prompt_id])
  end
end
