defmodule TwitchStory.Request.SiteHistory.ChatMessages do
  @moduledoc false

  alias TwitchStory.Request.Zipfile

  # require Explorer.DataFrame, as: DataFrame

  def read(file) do
    file
    |> Zipfile.csv(~c"request/site_history/chat_messages.csv")
  end
end
