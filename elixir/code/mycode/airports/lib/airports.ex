defmodule Airports do
  alias NimbleCSV.RFC4180, as: CSV

  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end

  def read_airport_use_stream(src, filter) do
    src.()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&row_binary_to_data/1)
    |> Stream.reject(filter)
    |> Enum.to_list()
  end

  def read_airport_use_flow(src, filter) do
    src.()
    |> File.stream!()
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
      [row] = CSV.parse_string(row, skip_headers: false)

      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
    |> Flow.reject(filter)
    |> Flow.partition(key: {:key, :country})
    # |> Flow.group_by(& &1.country)
    # |> Flow.map(fn {country, data} -> {country, Enum.count(data)} end)
    |> Flow.reduce(fn -> %{} end, fn item, acc ->
      Map.update(acc, item.country, 1, &(&1 + 1))
    end)
    |> Flow.take_sort(10, fn {_, a}, {_, b} -> a > b end)
    |> Flow.flat_map(fn x -> x end)
    |> Enum.to_list()
  end

  defp row_binary_to_data(row) do
    %{
      id: :binary.copy(Enum.at(row, 0)),
      type: :binary.copy(Enum.at(row, 2)),
      name: :binary.copy(Enum.at(row, 3)),
      country: :binary.copy(Enum.at(row, 8))
    }
  end

  def open_airports() do
    (&airports_csv/0)
    |> read_airport_use_flow(&(&1.type == "closed"))
  end
end
