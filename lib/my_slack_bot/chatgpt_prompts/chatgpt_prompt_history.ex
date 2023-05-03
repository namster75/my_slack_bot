defmodule MySlackBot.Chatgpt.ChatgptPromptHistory do
  use Ecto.Schema
  import Ecto.Changeset

  alias MySlackBot.Chatgpt.ChatgptPrompt

  schema "gpt_prompt_histories" do
    field :content, :string

    belongs_to :gpt_prompt, ChatgptPrompt

    timestamps()
  end

  @doc false
  def changeset(gpt_prompt_history, attrs) do
    gpt_prompt_history
    |> cast(attrs, [:content, :gpt_prompt_id])
    |> validate_required([:content, :gpt_prompt_id])
  end
end
