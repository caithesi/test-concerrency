defmodule BookingsPipeline do
  use Broadway
  @producer BroadwayRabbitMQ.Producer
  @producer_config [
    queue: "bookings_queue",
    declare: [durable: true],
    on_failure: :reject_and_requeue,
    connection: [
      username: "user",
      password: "password",
      host: "localhost",
      port: 5672
    ]
  ]
  def start_link(_args) do
    options = [
      name: BookingsPipeline,
      producer: [
        module: {@producer, @producer_config}
      ],
      processors: [
        default: []
      ],
      batchers: [
        default: [],
        cinema: [],
        musical: [],
        porn: []
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    %{data: %{event: event}} = message

    # TODO: check for tickets availability.
    if Tickets.tickets_available?(event) do
      case message do
        %{data: %{event: "cinema"}} = message -> Broadway.Message.put_batcher(message, :cinema)
        %{data: %{event: "musical"}} = message -> Broadway.Message.put_batcher(message, :musical)
        %{data: %{event: "porn"}} = message -> Broadway.Message.put_batcher(message, :porn)
        message -> message
      end
    else
      Broadway.Message.failed(message, "bookings-closed")
    end
  end

  def handle_failed(messages, _context) do
    IO.inspect(messages, label: "Failed Message")

    Enum.map(messages, fn
      %{status: {:failed, "bookings-closed"}} = message ->
        Broadway.Message.configure_ack(message, on_failure: :reject)

      message ->
        message
    end)
  end

  def handle_batch(_batcher, messages, batch_info, _context) do
    IO.puts(
      "#{inspect(self())} Batch #{batch_info.batcher} #{batch_info.batch_key} total message is #{Enum.count(messages)}"
    )

    # IO.inspect(batch_info, label: "#{inspect(self())}  Batch")
    messages
    |> Tickets.insert_all_tickets()
    |> Enum.each(&send_notify_after_insert/1)

    messages
  end

  def send_notify_after_insert(message) do
    channel = message.metadata.amqp_channel
    payload = "email,#{message.data.user.email}"
    AMQP.Basic.publish(channel, "", "notifications_queue", payload)
  end

  def prepare_messages(messages, _context) do
    #  Parse data and convert to a map.
    # IO.inspect(messages, label: "Message")

    t = fn message ->
      Broadway.Message.update_data(message, fn data ->
        [event, user_id] = String.split(data, ",")
        %{event: event, user_id: user_id}
      end)
    end

    messages = Enum.map(messages, t)

    users =
      messages
      |> Enum.map(& &1.data.user_id)
      |> Tickets.users_by_ids()

    # Put users in messages.
    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        user = Enum.find(users, &(&1.id == data.user_id))
        Map.put(data, :user, user)
      end)
    end)
  end
end
