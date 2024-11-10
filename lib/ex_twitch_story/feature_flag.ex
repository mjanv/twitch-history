defmodule TwitchStory.FeatureFlag do
  @moduledoc false

  @spec enabled?(atom()) :: boolean()
  def enabled?(feature), do: FunWithFlags.enabled?(feature)
end
