defmodule TwitchStory.FeatureFlagTest do
  use TwitchStory.DataCase

  alias TwitchStory.FeatureFlag

  @tag :wip
  test "enabled?/1 returns true if the feature is enabled" do
    assert FeatureFlag.enabled?(:eurovision) == true
  end

  test "enabled?/1 returns false if the feature is disabled" do
    assert FeatureFlag.enabled?(:other_game) == false
  end
end
