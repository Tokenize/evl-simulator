defmodule EvlSimulator.Event do
  @moduledoc """
  This module includes the needed functions and structure to return a simulated TPI event.
  """

  defstruct [:command, :zone, :partition, :mode, :user]

  def to_string(%EvlSimulator.Event{partition: nil, zone: zone} = event) when is_integer(zone) do
    [
      event.command,
      event.zone |> Integer.to_string() |> String.pad_leading(3, "0")
    ]
    |> Enum.join("")
  end

  def to_string(%EvlSimulator.Event{partition: nil, user: user} = event) when is_integer(user) do
    [
      event.command,
      event.user |> Integer.to_string() |> String.pad_leading(4, "0")
    ]
    |> Enum.join("")
  end

  def to_string(%EvlSimulator.Event{partition: partition, mode: mode} = event)
      when is_integer(partition) and is_integer(mode) do
    [
      event.command,
      event.partition |> Integer.to_string(),
      event.mode |> Integer.to_string()
    ]
    |> Enum.join("")
  end

  def to_string(%EvlSimulator.Event{partition: partition, user: user} = event)
      when is_integer(partition) and is_integer(user) do
    [
      event.command,
      event.partition |> Integer.to_string(),
      event.user |> Integer.to_string() |> String.pad_leading(4, "0")
    ]
    |> Enum.join("")
  end

  def to_string(%EvlSimulator.Event{partition: partition, zone: nil} = event)
      when is_integer(partition) do
    [
      event.command,
      event.partition |> Integer.to_string()
    ]
    |> Enum.join("")
  end

  def to_string(%EvlSimulator.Event{partition: partition, zone: zone} = event)
      when is_integer(zone) and is_integer(partition) do
    [
      event.command,
      event.partition |> Integer.to_string(),
      event.zone |> Integer.to_string() |> String.pad_leading(3, "0")
    ]
    |> Enum.join("")
  end

  def to_string(%EvlSimulator.Event{partition: nil, zone: nil} = event) do
    event.command
  end

  def total_zones do
    Application.get_env(:evl_simulator, :total_zones, 6)
  end

  def total_partitions do
    Application.get_env(:evl_simulator, :total_partitions, 1)
  end
end
