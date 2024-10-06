defmodule TwitchStory.FeatureFlagTest do
  use ExUnit.Case

  alias TwitchStory.FeatureFlag

  test "active?/1 returns true if the feature is enabled" do
    assert FeatureFlag.active?([:games, :eurovision]) == true
  end

  test "active?/1 returns false if the feature is disabled" do
    assert FeatureFlag.active?([:games, :other_game]) == false
  end
end
