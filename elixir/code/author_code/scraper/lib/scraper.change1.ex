#---
# Excerpted from "Concurrent Data Processing in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sgdpelixir for more book information.
#---
defmodule Scraper do
  @moduledoc """
  Documentation for Scraper.
  """

  def work() do
    # For simplicity, this function is
    # just a placeholder and does not contain
    # real scraping logic.
    1..5
    |> Enum.random()
    |> :timer.seconds()
    |> :timer.sleep()
  end

  def online?(_url) do
    # Pretend we are checking if the
    # service is online or not.
    work()

    # Select result randomly.
    Enum.random([false, true, true])
  end
end
