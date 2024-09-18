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
  require Logger

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
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    # Add your business logic here...
    IO.inspect(message, label: "Message")
  end

  def prepare_messages(messages, _context) do
    # Parse data and convert to a map.
    messages =
      Enum.map(messages, fn message ->
        Broadway.Message.update_data(message, fn data ->
          [event, user_id] = String.split(data, ",")
          %{event: event, user_id: user_id}
        end)
      end)

    users = Tickets.users_by_ids(Enum.map(messages, & &1.data.user_id))

    # Put users in messages.
    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        user = Enum.find(users, & &1.id == data.user_id)
        Map.put(data, :user, user)
      end)
    end)
  end
end
