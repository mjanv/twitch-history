defmodule TwitchStory.Notifications do
  @moduledoc false

  alias TwitchStory.Notifications.{Log, Mailer}

  defdelegate deliver_email(recipient, subject, body), to: Mailer
  defdelegate deliver_message(body), to: Log
end
