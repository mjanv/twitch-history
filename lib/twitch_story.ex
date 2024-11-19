defmodule TwitchStory do
  @moduledoc false

  def file_storage, do: Application.get_env(:twitch_story, :file_storage)

  @doc """
  Declares the list of existing feature flags
  """
  @spec feature_flags :: [atom()]
  def feature_flags do
    [
      # Twitch
      :live,
      :channels,
      :history,
      # Games
      :eurovision
    ]
  end
end
