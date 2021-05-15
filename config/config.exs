# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :evl_simulator, port: 4025
config :evl_simulator, password: "SECRET"
config :evl_simulator, total_zones: 6
config :evl_simulator, total_partitions: 1
config :evl_simulator, fuzzer: {EvlDaemon.Fuzzer.Connection, [interval: 5000]}

config :evl_simulator,
  event_engines: [
    {EvlSimulator.EventEngine.Activity, [event_interval: 1000]},
    {EvlSimulator.EventEngine.System, [event_interval: 10000]},
    {EvlSimulator.EventEngine.Alarm, [event_interval: 20000]}
  ]

config :logger, level: :debug
