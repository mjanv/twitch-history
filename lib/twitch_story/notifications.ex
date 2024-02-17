defmodule TwitchStory.Notifications do
  @moduledoc false

  alias TwitchStory.Notifications.Mailer

  defdelegate deliver_email(recipient, subject, body), to: Mailer, as: :deliver
end
