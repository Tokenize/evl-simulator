defmodule EvlSimulator.EventEngine.Activity do
  @moduledoc """
  This module has the methods to emit regular events for zones / partitions opening & closing...etc.
  """

  import EvlSimulator.Event, only: [total_zones: 0]
  require Logger
  require GenServer

  @activity_commands ~w(609 610)

  def start_link(opts = %{}) do
    Logger.debug("#{__MODULE__}.start_link (#{inspect opts})")

    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    {:ok, opts, opts.event_interval}
  end

  def handle_info(:timeout, state) do
    %EvlSimulator.Event {
      command: (@activity_commands |> Enum.random),
      zone: (1..total_zones() |> Enum.random)
    }
    |> EvlSimulator.Event.to_string
    |> EvlSimulator.Connection.send

    {:noreply, state, state.event_interval}
  end
end
