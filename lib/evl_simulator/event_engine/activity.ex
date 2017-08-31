defmodule EvlSimulator.EventEngine.Activity do
  @moduledoc """
  This module has the methods to emit regular events for zones / partitions opening & closing...etc.
  """

  import EvlSimulator.Event, only: [total_zones: 0]
  require Logger
  require GenServer
  use EvlSimulator.EventEngine

  @zone_events ~w(609 610)

  def events do
    @zone_events
  end

  def generate_event(event_code) do
    %EvlSimulator.Event {
      command: event_code,
      zone: (1..total_zones() |> Enum.random)
    }
  end
end
