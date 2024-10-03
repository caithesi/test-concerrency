# Tickets

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tickets` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tickets, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/tickets>.


this project require rabbit mq to run

docker run -d --hostname my-rabbit -p 15672:15672 -p 5672:5672 --name some-rabbit -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=password rabbitmq:3-management
