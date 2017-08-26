defmodule EvlSimulator.EventEngine.Alarm do
  @moduledoc """
  This module has the methods to emit alarm events for zones / partitions.
  """

  import EvlSimulator.Event, only: [total_zones: 0, total_partitions: 0]
  require Logger
  require GenServer

  @special_events ~w(620)
  @partition_events ~w(650 651 653 654 655 656 657 658 659 672 673 674 701 702 751)
  @partition_mode_events ~w(652)
  @partition_user_events ~w(700 750)
  @partition_zone_events ~w(601 602)
  #@events @partition_events ++ @partition_mode_events ++ @partition_user_events ++ @partition_zone_events
  @events @special_events

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

    @events
    |> Enum.random
    |> do_generate_event
    |> EvlSimulator.Event.to_string
    |> EvlSimulator.Connection.send

    {:noreply, state, state.event_interval}
  end

  # Private functions

  defp do_generate_event(event_code) when event_code in @partition_events do
    %EvlSimulator.Event {
      command: event_code,
      partition: (1..total_partitions() |> Enum.random)
    }
  end

  defp do_generate_event(event_code) when event_code in @special_events do
    %EvlSimulator.Event {
      command: event_code,
      user: 0
    }
  end

  defp do_generate_event(event_code) when event_code in @partition_mode_events do
    %EvlSimulator.Event {
      command: event_code,
      partition: (1..total_partitions() |> Enum.random),
      mode: (0..3 |> Enum.random)
    }
  end

  defp do_generate_event(event_code) when event_code in @partition_user_events do
    %EvlSimulator.Event {
      command: event_code,
      partition: (1..total_partitions() |> Enum.random),
      user: (1..42 |> Enum.random)
    }
  end

  defp do_generate_event(event_code) when event_code in @partition_zone_events do
    %EvlSimulator.Event {
      command: event_code,
      partition: (1..total_partitions() |> Enum.random),
      zone: (1..total_zones() |> Enum.random)
    }
  end
end
