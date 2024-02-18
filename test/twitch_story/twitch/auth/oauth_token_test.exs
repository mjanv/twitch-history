defmodule TwitchStory.Twitch.Auth.OauthTokenTest do
  @moduledoc false

  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

  alias TwitchStory.Twitch.Auth.OauthToken

  describe "create/2" do
    test "valid" do
      user = user_fixture()
      attrs = %{access_token: "abc", refresh_token: "def", scopes: ["chat:read"]}
      {:ok, %OauthToken{} = token} = OauthToken.create(attrs, user)

      assert token.user_id == user.id
      assert token.access_token == "abc"
      assert token.refresh_token == "def"
      assert token.scopes == ["chat:read"]
    end
  end

  describe "update/2" do
    test "valid" do
      user = user_fixture()
      attrs = %{access_token: "abc", refresh_token: "def", scopes: ["chat:read"]}
      {:ok, %OauthToken{}} = OauthToken.create(attrs, user)

      attrs = %{access_token: "ghi", refresh_token: "jkl", scopes: ["chat:write"]}
      {:ok, %OauthToken{} = token} = OauthToken.update(attrs, user)

      assert OauthToken.count() == 1
      assert token.user_id == user.id
      assert token.access_token == "ghi"
      assert token.refresh_token == "jkl"
      assert token.scopes == ["chat:write"]
    end
  end

  describe "get/1" do
    test "returns the token with given user" do
      user = user_fixture()

      attrs = %{access_token: "abc", refresh_token: "def", scopes: ["chat:read"]}
      {:ok, %OauthToken{} = token} = OauthToken.create(attrs, user)
      assert OauthToken.get(user) == token
    end
  end
end
