defmodule TwitchStory.Notifications.Log do
  @moduledoc false

  require Logger

  def deliver_message(body) when is_binary(body) do
    Logger.warning(body)
  end
end
