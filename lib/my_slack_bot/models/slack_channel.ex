defmodule MySlackBot.Models.SlackChannel do
  use Ecto.Schema
  import Ecto.Changeset

  alias MySlackBot.Models.SlackMember
  alias MySlackBot.Models.SlackTask

  schema "slack_channels" do
    field :channel_id, :string
    field :channel_name, :string

    has_many :slack_members, SlackMember
    has_many :slack_tasks, SlackTask

    timestamps()
  end

  @doc false
  def changeset(slack_channel, attrs) do
    slack_channel
    |> cast(attrs, [:channel_id, :channel_name])
    |> validate_required([:channel_id, :channel_name])
    |> unique_constraint(:channel_id)
    |> unique_constraint(:channel_name)
  end
end
