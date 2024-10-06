defmodule TwitchStory.FeatureFlag do
  @moduledoc false

  @spec active?([atom()]) :: boolean()
  def active?(keys) do
    :twitch_story
    |> Application.get_env(:feature_flags)
    |> get_in(keys)
    |> case do
      nil -> false
      _ -> true
    end
  end
end
