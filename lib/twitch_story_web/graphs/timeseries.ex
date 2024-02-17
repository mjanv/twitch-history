defmodule TwitchStoryWeb.Graphs.Timeseries do
  @moduledoc false

  require VegaLite, as: Vl

  def bar(data, title \\ "") do
    Vl.new(title: title, width: :container, height: :container, padding: 5)
    |> Vl.config(
      title: [anchor: "start", color: "#ffffff"],
      view: [stroke: :transparent],
      background: nil
    )
    |> Vl.data_from_values(data, only: ["date", "total"])
    |> Vl.mark(:bar, tooltip: true, color: "#a870ff", corner_radius_end: 3)
    |> Vl.encode_field(:x, "date", type: :ordinal, title: nil, axis: [label_color: "#ffffff"])
    |> Vl.encode_field(:y, "total", type: :quantitative, title: nil, axis: nil)
  end
end
