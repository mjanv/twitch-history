defmodule TwitchStory.Request.Zipfile do
  @moduledoc false

  require Explorer.DataFrame, as: DataFrame

  def list(file) do
    file
    |> :zip.list_dir()
    |> then(fn {:ok, list} -> list end)
    |> Enum.map(fn
      {:zip_comment, _} -> nil
      {:zip_file, path, _, _, _, _} -> path
    end)
    |> Enum.reject(&is_nil/1)
  end

  def read(file, path) do
    with {:ok, handle} <- :zip.zip_open(file, [:memory]),
         {:ok, {_, binary}} <- :zip.zip_get(path, handle) do
      binary
    end
  end

  def json(file, path) do
    Jason.decode!(read(file, path))
  end

  def csv(file, path, opts \\ []) do
    with {:ok, [path]} <- :zip.extract(file, [{:file_list, [path]}]),
         {:ok, df} <- DataFrame.from_csv(List.to_string(path), opts) do
      df
    end
  end
end
