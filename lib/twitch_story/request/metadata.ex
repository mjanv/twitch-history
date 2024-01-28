defmodule TwitchStory.Request.Metadata do
  @moduledoc false

  defstruct [:username, :user_id, :request_id, :start_time, :end_time]

  alias TwitchStory.Request.Zipfile

  def read(file) do
    file
    |> Zipfile.json(~c"request/metadata.json")
    |> case do
      %{
        "Username" => username,
        "UserID" => user_id,
        "RequestID" => request_id,
        "StartTime" => start_time,
        "EndTime" => end_time
      } ->
        %__MODULE__{
          username: username,
          user_id: user_id,
          request_id: request_id,
          start_time: start_time,
          end_time: end_time
        }
    end
  end
end
