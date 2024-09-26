defmodule Airport do
  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end
end
