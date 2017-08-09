defmodule EvlSimulator.EventEngine.Activity do
  @moduledoc """
  This module has the methods to emit regular events for zones / partitions opening & closing...etc.
  """

  require Logger
  require GenServer

  def start_link do
    event_interval = Application.get_env(:evl_simulator, :event_interval, 1000)
    GenServer.start_link(__MODULE__, %{event_interval: event_interval}, [])
  end

  def init(opts) do
    {:ok, opts, opts.event_interval}
  end

  def handle_info(:timeout, state) do
    EvlSimulator.Event.new |> EvlSimulator.Event.to_string |> EvlSimulator.Connection.send

    {:noreply, state, state.event_interval}
  end
end
