#---
# Excerpted from "Concurrent Data Processing in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sgdpelixir for more book information.
#---
defmodule Jobber do
  alias Jobber.{JobRunner, JobSupervisor}

  def start_job(args) do
    if Enum.count(running_imports()) >= 5 do
      {:error, :import_quota_reached}
    else
      DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
    end
  end

  def running_imports() do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:"==", :"$3", "import"}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]
    Registry.select(Jobber.JobRegistry, [{match_all, guards, map_result}])
  end
end
