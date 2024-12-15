defmodule TwitchStory.Twitch.Histories.Summary do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias TwitchStory.Dataflow.Statistics
  alias TwitchStory.Twitch.Histories.{Commerce, Community, SiteHistory}

  @type t() :: %__MODULE__{
          follows: integer(),
          chat_messages: integer(),
          hours_watched: integer(),
          subscriptions: integer()
        }

  @primary_key false
  embedded_schema do
    field :follows, :integer
    field :chat_messages, :integer
    field :hours_watched, :integer
    field :subscriptions, :integer
  end

  def changeset(summary, attrs \\ %{}) do
    summary
    |> cast(attrs, [:follows, :chat_messages, :hours_watched, :subscriptions])
    |> validate_required([:follows, :chat_messages, :hours_watched, :subscriptions])
  end

  @doc "Returns a summary of a history"
  @spec new(String.t()) :: t()
  def new(file) do
    %__MODULE__{
      follows: file |> Community.Follows.read() |> Statistics.n_rows(),
      chat_messages: file |> SiteHistory.ChatMessages.read() |> Statistics.n_rows(),
      hours_watched: file |> SiteHistory.MinuteWatched.read() |> Statistics.n_rows(60),
      subscriptions: file |> Commerce.Subs.read() |> Statistics.n_rows()
    }
  end
end
