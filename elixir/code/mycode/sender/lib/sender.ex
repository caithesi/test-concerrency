defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Sender.hello()
      :world

  """
  def hello do
    :world
  end

  def send_email("yiyang@cn.com" = email), do: :error

  def send_email(email) do
    Process.sleep(3000)

    IO.puts("Email to #{email} sent")
    {:ok, "email_sent"}
  end

  def notify_all(emails) do
    Sender.EmailTaskSupervisor
    |> Task.Supervisor.async_stream(emails, &send_email/1)
    |> Enum.to_list()
  end
end
