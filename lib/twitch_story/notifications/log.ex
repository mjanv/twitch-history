defmodule TwitchStory.Notifications.Log do
  @moduledoc false

  @behaviour TwitchStory.EventBus.Dispatcher

  require Logger

  def deliver_message(body) when is_binary(body) do
    Logger.warning(body)
  end

  def dispatch(event) do
    Logger.info("#{inspect(event)}")
  end
end
