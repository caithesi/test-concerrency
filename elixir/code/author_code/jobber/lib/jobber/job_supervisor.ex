#---
# Excerpted from "Concurrent Data Processing in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sgdpelixir for more book information.
#---
defmodule Jobber.JobSupervisor do
  use Supervisor, restart: :temporary

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    children = [
      {Jobber.Job, args}
    ]

    options = [
      strategy: :one_for_one,
      max_seconds: 30
    ]

    Supervisor.init(children, options)
  end
end
