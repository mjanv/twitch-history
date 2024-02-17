defmodule TwitchStory.Notifications.MailerTest do
  use ExUnit.Case, async: true

  import Swoosh.TestAssertions

  alias TwitchStory.Notifications.Mailer

  test "An email can be sent to a recipient with a title and body" do
    Mailer.deliver_email("user@example.com", "Title", "Body")

    assert_email_sent(subject: "Title", text_body: "Body", to: {"", "user@example.com"})
  end
end
