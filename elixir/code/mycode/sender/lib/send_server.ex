defmodule SendServer do
  use GenServer
  @type send_mail_status :: :sent | :fail
  defmodule State do
    defstruct emails: [], max_retry: 5
  end

  def init(init_arg) do
    IO.puts("received args : #{inspect(init_arg)}")
    max_retries = Keyword.get(init_arg, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}
    Process.send_after(self(), :retry, 5000)
    {:ok, state, {:continue, :add_author_mail}}
  end

  def handle_continue(:add_author_mail, state) do
    {:noreply, Map.put(state, :admin, "caithesi")}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:send, email}, state) do
    Sender.send_email(email)

    status =
      case Sender.send_email(email) do
        {:ok, "email_sent"} -> :sent
        :error -> :fail
      end

    emails = [%{email: email, status: status, retries: 0}] ++ state.emails

    {:noreply, %{state | emails: emails}}
  end

  def handle_info(:retry, state) do
    {failed, done} =
      Enum.split_with(state.emails, fn item ->
        item.status == :fail && item.retries < state.max_retries
      end)

    retried = Enum.map(failed, &retry_send_email/1)

    Process.send_after(self(), :retry, 5000)

    {:noreply, %{state | emails: retried ++ done}}
  end

  defp retry_send_email(item) do
    IO.puts("Retrying email  #{item.email}  ...")

    new_status =
      case Sender.send_email(item.email) do
        {:ok, "email_sent"} -> :sent
        :error -> :fail
      end

    %{email: item.email, status: new_status, retries: item.retries + 1}
  end
end
