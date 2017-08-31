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
