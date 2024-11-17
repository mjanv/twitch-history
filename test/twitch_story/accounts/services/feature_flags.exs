defmodule TwitchStory.Accounts.Services.FeatureFlagsTest do
  use TwitchStory.DataCase

  alias TwitchStory.Accounts.Services.FeatureFlags
  alias TwitchStory.Accounts.User
  alias TwitchStory.FeatureFlag

  setup do
    user = user_fixture()

    {:ok, user: user}
  end

  describe "enable/2" do
    test "activates a feature flag for a user", %{user: user} do
      before_flag = FeatureFlag.enabled?(:test, user)

      :ok = FeatureFlags.enable(user.email, :test)

      after_flag = FeatureFlag.enabled?(:test, user)

      assert {before_flag, after_flag} == {false, true}
    end

    test "deactivates a feature flag for a user", %{user: user} do
      before_flag = FeatureFlag.enabled?(:test, user)

      :ok = FeatureFlags.disable(user.email, :test)

      after_flag = FeatureFlag.enabled?(:test, user)

      assert {before_flag, after_flag} == {true, false}
    end
  end
end
