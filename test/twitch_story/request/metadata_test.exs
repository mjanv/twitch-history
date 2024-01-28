defmodule TwitchStory.Request.MetadataTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Request.Metadata

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    metadata = Metadata.read(@zip)

    assert metadata == %Metadata{
             end_time: "2024-01-06T23:00:00Z",
             request_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
             start_time: "2019-06-14T22:01:14.843812Z",
             user_id: "441903922",
             username: "lanfeust313"
           }
  end
end
