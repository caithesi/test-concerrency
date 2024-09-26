defmodule Airport do
  alias NimbleCSV.RFC4180, as: CSV

  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end

  def read_airport_to_map(src, filter) do
    src.()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn row ->
      %{
        id: :binary.copy(Enum.at(row, 0)),
        type: :binary.copy(Enum.at(row, 2)),
        name: :binary.copy(Enum.at(row, 3)),
        country: :binary.copy(Enum.at(row, 8))
      }
    end)
    |> Stream.reject(filter)
  end

  def open_airports() do
    (&airports_csv/0)
    |> read_airport_to_map(&(&1.type == "closed"))
    |> Enum.to_list()
  end
end
