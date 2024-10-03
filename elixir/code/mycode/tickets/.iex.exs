send_messages =  fn num_messages ->
  { :ok, connection} = AMQP.Connection.open(
    username: "user",
    password: "password",
    host: "localhost",
    port: 5672)

  { :ok, channel} = AMQP.Channel.open(connection)

  Enum.each(1..num_messages, fn _ ->
    event = Enum.random(["cinema", "musical", "play", "porn"])
    user_id = Enum.random(1..10)
    AMQP.Basic.publish(channel, "", "bookings_queue", "#{event},#{user_id}")
  end)
  AMQP.Connection.close(connection)
end
