defmodule MySlackBot.Models.SlackTask do
  use Ecto.Schema
  import Ecto.Changeset

  alias MySlackBot.Models.SlackChannel

  schema "slack_tasks" do
    field :hour, :integer
    field :minute, :integer
    field :name, :string
    field :status, Ecto.Enum, values: [:active, :paused]
    field :command, Ecto.Enum, values: [:pick, :generate_random_prompt]
    field :command_argument, :string

    belongs_to :slack_channel, SlackChannel

    embeds_one(:days, DayOfWeekValues, on_replace: :delete, primary_key: false) do
      field :monday, :boolean, default: false
      field :tuesday, :boolean, default: false
      field :wednesday, :boolean, default: false
      field :thursday, :boolean, default: false
      field :friday, :boolean, default: false
      field :saturday, :boolean, default: false
      field :sunday, :boolean, default: false
    end

    timestamps()
  end

  @doc false
  def changeset(slack_task, attrs) do
    slack_task
    |> cast(attrs, [:slack_channel_id, :name, :hour, :minute, :status, :command, :command_argument])
    |> cast_embed(:days, with: &changeset_days/2)
    |> validate_required([:slack_channel_id, :name, :days, :hour, :minute, :status, :command])
    |> validate_inclusion(:status, [:active, :paused])
    |> validate_inclusion(:hour, 0..23)
    |> validate_inclusion(:minute, 0..59)
    |> validate_inclusion(:command, [:pick, :generate_random_prompt])
    |> unique_constraint([:name, :slack_channel_id])
  end

  defp changeset_days(days, attrs) do
    days
    |> cast(attrs, [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday])
    |> validate_required([:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday])
  end
end
