#---
# Excerpted from "Concurrent Data Processing in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sgdpelixir for more book information.
#---
defmodule BookingsPipeline do
  use Broadway

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    queue: "bookings_queue",
    declare: [durable: true],
    on_failure: :reject_and_requeue
  ]

  def start_link(_args) do
    options = [
      name: BookingsPipeline,
      producer: [module: {@producer, @producer_config}],
      processors: [
        default: []
      ],
      batchers: [
        default: []
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    %{data: %{event: event, user: user}} = message

    if Tickets.tickets_available?(event) do
      Tickets.create_ticket(user, event)
      Tickets.send_email(user)
      IO.inspect(message, label: "Message")
    else
      Broadway.Message.failed(message, "bookings-closed")
    end
  end

  def prepare_messages(messages, _context) do
    messages =
      Enum.map(messages, fn message ->
        Broadway.Message.update_data(message, fn data ->
          [event, user_id] = String.split(data, ",")
          %{event: event, user_id: user_id}
        end)
      end)

    users = Tickets.users_by_ids(Enum.map(messages, & &1.data.user_id))

    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        user = Enum.find(users, & &1.id == data.user_id)
        Map.put(data, :user, user)
      end)
    end)
  end

  def handle_failed(messages, _context) do
    IO.inspect(messages, label: "Failed messages")

    Enum.map(messages, fn
      %{status: {:failed, "bookings-closed"}} = message ->
        Broadway.Message.configure_ack(message, on_failure: :reject)

      message ->
        message
    end)
  end

  def handle_batch(_batcher, messages, batch_info, _context) do
    IO.inspect(batch_info, label: "#{inspect(self())} Batch")

    messages
  end
end
