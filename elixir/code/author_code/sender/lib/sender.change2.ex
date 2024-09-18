#---
# Excerpted from "Concurrent Data Processing in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sgdpelixir for more book information.
#---
defmodule Sender do
  @moduledoc """
  Documentation for Sender.
  """

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    {:ok, "email_sent"}
  end

  def notify_all(emails) do
    emails
    |> Enum.map(fn email ->
      Task.async(fn ->
        send_email(email)
      end)
    end)
    |> Enum.map(&Task.await/1)
  end
end
