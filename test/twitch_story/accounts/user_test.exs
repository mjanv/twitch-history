defmodule TwitchStory.Accounts.UserTest do
  use TwitchStory.DataCase

  alias TwitchStory.Accounts.User

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
