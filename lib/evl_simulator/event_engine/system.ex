defmodule EvlSimulator.EventEngine.System do
  @moduledoc """
  This module has the methods to emit system events / failures.
  """

  import EvlSimulator.Event, only: [total_partitions: 0, total_zones: 0]
  require Logger
  require GenServer

  @system_events ~w(501 560 631 632 800 801 802 803 806 807 814 816 829 830 842 843)
  @partition_events ~w(663 664 670 671 840 841)
  @partition_zone_events ~w(603 604 605 606)
  @events @system_events ++ @partition_events ++ @partition_zone_events

  def start_link(opts = %{}) do
    Logger.debug("#{__MODULE__}.start_link (#{inspect opts})")

    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    {:ok, opts, opts.event_interval}
  end

  def handle_info(:timeout, state) do
    @events
    |> Enum.random
    |> do_generate_event
    |> EvlSimulator.Event.to_string
    |> EvlSimulator.Connection.send

    {:noreply, state, state.event_interval}
  end

  # Private functions

  defp do_generate_event(event_code) when event_code in @system_events do
    %EvlSimulator.Event { command: event_code }
  end

  defp do_generate_event(event_code) when event_code in @partition_events do
    %EvlSimulator.Event {
      command: event_code,
      partition: (1..total_partitions() |> Enum.random)
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
