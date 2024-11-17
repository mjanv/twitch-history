defmodule TwitchStory do
  @moduledoc false

  @doc """
  Declares the list of existing feature flags
  """
  @spec feature_flags :: [atom()]
  def feature_flags do
    [
      :live,
      :eurovision
    ]
  end
end
