defmodule MySlackBot.Chatgpt.ChatgptPrompt do
  use Ecto.Schema
  import Ecto.Changeset

  alias MySlackBot.Models.SlackChannel

  schema "gpt_prompts" do
    field :message, :string

    belongs_to :slack_channel, SlackChannel

    timestamps()
  end

  @doc false
  def changeset(gpt_prompt, attrs) do
    gpt_prompt
    |> cast(attrs, [:message, :slack_channel_id])
    |> validate_required([:message, :slack_channel_id])
    |> unique_constraint([:message, :slack_channel_id])
  end
end
