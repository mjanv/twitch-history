defmodule TwitchStory.Request.SiteHistory.ChatMessages do
  @moduledoc false

  alias TwitchStory.Request.Zipfile

  # require Explorer.DataFrame, as: DataFrame

  def read(file) do
    file
    |> Zipfile.csv(
      ~c"request/site_history/chat_messages.csv",
      columns: [
        "time",
        "channel",
        "body",
        "body_full",
        "is_reply",
        "is_mention",
        "channel_points_modification"
      ],
      dtypes: [{"time", {:datetime, :microsecond}}]
    )
  end
end
