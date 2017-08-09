# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :evl_simulator, port: 4025
config :evl_simulator, password: "SECRET"
config :evl_simulator, event_interval: 2000
config :evl_simulator, total_zones: 6
config :evl_simulator, total_partitions: 1
config :logger, level: :debug
