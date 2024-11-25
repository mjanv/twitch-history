defmodule TwitchStoryWeb.Graphs.Timeseries do
  @moduledoc false

  require VegaLite, as: Vl

  def bar(data, title \\ "", x \\ "date", y \\ "total") do
    Vl.new(title: title, width: :container, height: :container, padding: 5)
    |> Vl.config(
      title: [anchor: "start", color: "#ffffff"],
      view: [stroke: :transparent],
      background: nil
    )
    |> Vl.data_from_values(data, only: [x, y])
    |> Vl.mark(:bar, tooltip: true, color: "#a870ff", corner_radius_end: 3)
    |> Vl.encode_field(:x, x, type: :ordinal, title: "date", axis: [label_color: "#ffffff"])
    |> Vl.encode_field(:y, y, type: :quantitative, title: String.capitalize(y), axis: nil)
    |> Vl.to_spec()
  end
end
