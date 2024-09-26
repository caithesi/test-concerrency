defmodule Airport do
  alias NimbleCSV.RFC4180, as: CSV

  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end

  def read_airport_to_map(src) do
    src.()
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.map(fn row ->
      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
  end

  def open_airports() do
    (&airports_csv/0)
    |> read_airport_to_map()
    |> Enum.reject(&(&1.type == "closed"))
  end
end
