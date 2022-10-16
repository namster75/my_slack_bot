defmodule MySlackBot.Models.SlackMember do
  use Ecto.Schema
  import Ecto.Changeset

  alias MySlackBot.Models.SlackChannel

  schema "slack_members" do
    field :name, :string

    belongs_to :slack_channel, SlackChannel

    timestamps()
  end

  @doc false
  def changeset(slack_member, attrs) do
    slack_member
    |> cast(attrs, [:name, :slack_channel_id])
    |> validate_required([:name, :slack_channel_id])
    |> unique_constraint([:name, :slack_channel_id])
  end
end
