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

  def open_airports(read_fn) do
    (&airports_csv/0)
    |> read_fn.(&(&1.type == "closed"))
  end
end
