#---
# Excerpted from "Concurrent Data Processing in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sgdpelixir for more book information.
#---
defmodule Airports do
  alias NimbleCSV.RFC4180, as: CSV

  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end

  def open_airports() do
    airports_csv()
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
    |> Stream.reject(&(&1.type == "closed"))
    |> Enum.to_list()
  end
end
