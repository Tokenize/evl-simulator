# EvlSimulator

**An Elixir simulator for the Envisa TPI (DSC) module**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `evl_simulator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:evl_simulator, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/evl_simulator](https://hexdocs.pm/evl_simulator).

### Docker

The provided Dockerfile can be used to install and run evl-simulator interactively without requiring Erlang or Elixir to be installed on your system.

```shell
docker build -t evlsimulator:latest .
docker run -it -p 4025:4025 evlsimulator:latest
```

## Usage

You can use the simulator in one of the two following modes:

### Automatic event generation

All you have to do is edit *config/config.exs* and enable the event engines that you
are interested in and define the event generation interval.

### Manual event generation

Edit *config/config.exs* and make the following changes:

```elixir
config :evl_simulator, event_engines: []
```

Run ```iex -S mix``` then generate the events directly by doing the following:

```elixir
# If you want to use the Event struct then you can do
%EvlSimulator.Event {command: "609", zone: 1}
|> EvlSimulator.Event.to_string
|> EvlSimulator.Connection.send

# If you know the raw string for the event and its parameters then pass it directly to
# the connection module
"6091" |> EvlSimulator.Connection.send
```

### Fuzzer

You can optionally enable a simple fuzzer (by uncommenting the relevant section in
*config/config.exs*) which will randomly re-arrange the encoded payload prior to sending
it to the client every 10_000 msecs (this can be changed in the config).
