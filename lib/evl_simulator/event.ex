defmodule EvlSimulator.Event do
  @moduledoc """
  This module includes the needed functions and structure to return a simulated TPI event.
  """

  defstruct [:command, :zone, :partition]

  def to_string(%EvlSimulator.Event{partition: nil, zone: zone} = event) when is_integer(zone) do
    [
      event.command,
      event.zone |> Integer.to_string |> String.pad_leading(3, "0")
    ]
    |> Enum.join("")
  end

  def total_zones do
    Application.get_env(:evl_simulator, :total_zones, 6)
  end

  def total_partitions do
    Application.get_env(:evl_simulator, :total_partitions, 1)
  end
end
