#---
# Excerpted from "Concurrent Data Processing in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sgdpelixir for more book information.
#---
defmodule ScrapingPipeline do
  use Broadway
  require Logger

  def start_link(_args) do
    options = [
      name: ScrapingPipeline,
      producer: [
        module: {PageProducer, []},
        transformer: {ScrapingPipeline, :transform, []}
      ],
      processors: [
        default: [max_demand: 1, concurrency: 2]
      ],
      batchers: [
        default: [batch_size: 1, concurrency: 2],
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    if Scraper.online?(message.data) do
      Broadway.Message.put_batch_key(message, message.data)
    else
      Broadway.Message.failed(message, "offline")
    end
  end

  def handle_batch(_batcher, [message], _batch_info, _context) do
    Logger.info("Batch Processor received #{message.data}")
    Scraper.work()
    [message]
  end

  def transform(event, _options) do
    %Broadway.Message{
      data: event,
      acknowledger: {ScrapingPipeline, :pages, []}
    }
  end

  def ack(:pages, _successful, _failed) do
    :ok
  end
end
