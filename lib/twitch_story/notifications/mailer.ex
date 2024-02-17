defmodule TwitchStory.Notifications.Mailer do
  @moduledoc false

  use Swoosh.Mailer, otp_app: :twitch_story

  import Swoosh.Email

  def deliver_email(recipient, subject, body) do
    new()
    |> to(recipient)
    |> from({"TwitchStory", "contact@example.com"})
    |> subject(subject)
    |> text_body(body)
    |> then(fn email ->
      {:ok, _metadata} = __MODULE__.deliver(email)
      {:ok, email}
    end)
  end
end
