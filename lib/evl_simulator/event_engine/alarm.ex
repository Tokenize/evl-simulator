defmodule EvlSimulator.EventEngine.Alarm do
  @moduledoc """
  This module has the methods to emit alarm events for zones / partitions.
  """

  import EvlSimulator.Event, only: [total_zones: 0, total_partitions: 0]
  require Logger
  require GenServer
  use EvlSimulator.EventEngine

  @special_events ~w(620)
  @partition_events ~w(650 651 653 654 655 656 657 658 659 672 673 674 701 702 751)
  @partition_mode_events ~w(652)
  @partition_user_events ~w(700 750)
  @partition_zone_events ~w(601 602)

  # EventEngine overrides

  def events do
    @partition_events ++ @partition_mode_events ++ @partition_user_events ++ @partition_zone_events
  end

  def generate_event(event_code) do
    event_code
    |> do_generate_event
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
