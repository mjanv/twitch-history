defmodule TwitchStory.Zipfile do
  @moduledoc false

  require Explorer.DataFrame, as: DataFrame

  @doc "Returns the list of files in a zip file"
  @spec list(String.t()) :: [String.t()]
  def list(file) do
    file
    |> to_charlist()
    |> :zip.list_dir()
    |> then(fn {:ok, list} -> list end)
    |> Enum.map(fn
      {:zip_comment, _} -> nil
      {:zip_file, path, _, _, _, _} -> path
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&to_string/1)
  end

  @doc "Returns the content of a JSON file in a zip file"
  @spec json(String.t(), String.t()) :: term() | nil
  def json(file, path) do
    with {:ok, [path]} <- :zip.extract(to_charlist(file), [{:file_list, [to_charlist(path)]}]),
         {:ok, binary} <- File.read(path),
         {:ok, map} <- Jason.decode(binary) do
      map
    else
      _ -> nil
    end
  end

  @doc "Returns the content of a CSV file in a zip file"
  @spec csv(String.t(), String.t(), Keyword.t()) :: Explorer.DataFrame.t() | nil
  def csv(file, path, opts \\ []) do
    with {:ok, [path]} <- :zip.extract(to_charlist(file), [{:file_list, [to_charlist(path)]}]),
         {:ok, df} <- DataFrame.from_csv(List.to_string(path), opts) do
      df
    else
      _ -> nil
    end
  end
end
