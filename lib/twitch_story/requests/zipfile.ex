defmodule TwitchStory.Requests.Zipfile do
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

  def json(file, path) do
    with {:ok, [path]} <- :zip.extract(file, [{:file_list, [path]}]),
         {:ok, binary} <- File.read(path),
         {:ok, map} <- Jason.decode(binary) do
      map
    end
  end

  def csv(file, path, opts \\ []) do
    with {:ok, [path]} <- :zip.extract(file, [{:file_list, [path]}]),
         {:ok, df} <- DataFrame.from_csv(List.to_string(path), opts) do
      df
    end
  end
end
