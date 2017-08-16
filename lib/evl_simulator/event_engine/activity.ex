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
    Registry.register(Registry.EvlSimulator, "event_engines", __MODULE__)

    {:ok, opts, :hibernate}
  end

  def pause(pid) do
    Logger.debug("Pausing #{__MODULE__} event generation.")

    GenServer.cast(pid, :pause)
  end

  def resume(pid) do
    Logger.debug("Resuming #{__MODULE__} event generation.")

    GenServer.cast(pid, :resume)
  end

  # GenServer callbacks

  def handle_cast(:pause, state) do
    {:noreply, state, :hibernate}
  end

  def handle_cast(:resume, state) do
    {:noreply, state, state.event_interval}
  end

  def handle_info(:timeout, state) do
    Logger.debug("Generating #{__MODULE__} event.")

    %EvlSimulator.Event {
      command: (@activity_commands |> Enum.random),
      zone: (1..total_zones() |> Enum.random)
    }
    |> EvlSimulator.Event.to_string
    |> EvlSimulator.Connection.send

    {:noreply, state, state.event_interval}
  end
end
