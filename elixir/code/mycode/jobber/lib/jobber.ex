defmodule Jobber do
  alias Jobber.{JobRunner, JobSupervisor, Job}

  def start_job(args) do
    DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
    # DynamicSupervisor.start_child(JobRunner, {Job, args})
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
