defmodule TwitchStory.Graphs.Timeseries do
  @moduledoc false

  require VegaLite, as: Vl

  def line(data, title \\ "") do
    Vl.new(title: title, width: :container, height: :container, padding: 5)
    |> Vl.data_from_values(data, only: ["date", "total"])
    |> Vl.mark(:line)
    |> Vl.encode_field(:x, "date", type: :nominal)
    |> Vl.encode_field(:y, "total", type: :quantitative)
  end
end
