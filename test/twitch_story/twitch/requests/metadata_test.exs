defmodule TwitchStory.Twitch.Requests.MetadataTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Twitch.Requests.Metadata

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    metadata = Metadata.read(@zip)

    assert metadata == %Metadata{
             user_id: "441903922",
             username: "lanfeust313",
             request_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
             start_time: ~U[2019-06-14 22:01:14.843812Z],
             end_time: ~U[2024-01-06 23:00:00Z]
           }
  end
end
