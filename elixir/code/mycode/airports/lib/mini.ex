defmodule Mini do
  alias NimbleCSV.RFC4180, as: CSV

  def mini_airports_csv() do
    Application.app_dir(:airports, "/priv/mini.csv")
  end

  def read_airport_use_flow(src, filter) do
    window = Flow.Window.trigger_every(Flow.Window.global(), 5)

    src.()
    |> File.stream!()
    |> Stream.map(fn event ->
      Process.sleep(Enum.random([0, 0, 0, 1]))
      event
    end)
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
    |> Flow.partition(window: window, key: {:key, :country})
    |> Flow.group_by(& &1.country)
    |> Flow.on_trigger(&trigger/3)
    |> Enum.to_list()
  end

  defp trigger(acc, _partition_info, {_type, _id, trigger}) do
    # Show progress in IEx, or use the data for something else.​
    IO.puts("*****read acc******* [#{inspect(self())}] => #{inspect(acc)}  [********READ DONE ********]")
    old_count = Map.split_with(acc, fn {key, _value} -> is_atom(key) end)
    IO.puts("*****read count******* [#{inspect(self())}] #{inspect(old_count)}")
    event =
      acc
      |> Enum.map(fn {country, data} -> {country, Enum.count(data)} end)
      |> IO.inspect(label: inspect(self()))

    case trigger do
      :done -> {event, %{count: event}}
      {:every, 5} -> {[], %{count: event}}
    end
  end

  def open_airports() do
    (&mini_airports_csv/0)
    |> read_airport_use_flow(&(&1.type == "closed"))
  end
end
