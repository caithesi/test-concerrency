#---
# Excerpted from "Concurrent Data Processing in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sgdpelixir for more book information.
#---
send_messages = fn num_messages ->
  {:ok, connection} = AMQP.Connection.open()
  {:ok, channel} = AMQP.Channel.open(connection)

  Enum.each(1..num_messages, fn _ ->
    event = Enum.random(["cinema", "musical", "play"])
    user_id = Enum.random(1..3)
    AMQP.Basic.publish(channel, "", "bookings_queue", "#{event},#{user_id}")
  end)

  AMQP.Connection.close(connection)
end
