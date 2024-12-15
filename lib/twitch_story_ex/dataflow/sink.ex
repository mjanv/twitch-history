defmodule TwitchStory.Dataflow.Sink do
  @moduledoc false

  @callback read(String.t()) :: nil | Explorer.DataFrame.t()

  defmacro __using__(opts) do
    file = Keyword.get(opts, :file)
    columns = Keyword.get(opts, :columns)

    quote do
      @behaviour unquote(__MODULE__)

      alias TwitchStory.Zipfile

      @impl true
      def read(file) do
        Zipfile.csv(
          unquote(file),
          unquote(columns),
          dtypes: [{"time", {:naive_datetime, :microsecond}}]
        )
      end
    end
  end
end
