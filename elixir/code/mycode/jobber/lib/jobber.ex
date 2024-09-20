defmodule Jobber do
  alias Jobber.{JobRunner, JobSupervisor, Job}

  def start_job(args) do
    DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
    # DynamicSupervisor.start_child(JobRunner, {Job, args})
  end

  def running_imports() do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:"==", :"$3", "import"}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]
    Registry.select(Jobber.JobRegistry, [{match_all, guards, map_result}])
  end

  @moduledoc """
  Documentation for `Jobber`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Jobber.hello()
      :world

  """
  def hello do
    :world
  end
end
