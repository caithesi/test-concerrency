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
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    IO.inspect(message, label: "Message")
  end
end
