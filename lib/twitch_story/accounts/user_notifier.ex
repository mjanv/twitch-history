defmodule TwitchStory.Accounts.UserNotifier do
  @moduledoc false

  alias TwitchStory.Accounts.User
  alias TwitchStory.Notifications

  def deliver_confirmation_instructions(%User{email: email}, url) do
    Notifications.deliver_email(email, "Confirmation instructions", """

    ==============================

    Hi #{email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  def deliver_reset_password_instructions(%User{email: email}, url) do
    Notifications.deliver_email(email, "Reset password instructions", """

    ==============================

    Hi #{email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  def deliver_update_email_instructions(%User{email: email}, url) do
    Notifications.deliver_email(email, "Update email instructions", """

    ==============================

    Hi #{email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
