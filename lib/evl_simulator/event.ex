defmodule EvlSimulator.Event do
  @moduledoc """
  This module includes the needed functions and structure to return a simulated TPI event.
  """

  defstruct [:command, :zone, :partition, :state]

  def new do
    %EvlSimulator.Event{
      command: ~w(609 610) |> Enum.random,
      zone: (1..total_zones() |> Enum.random) |> Integer.to_string,
      partition: (1..total_partitions() |> Enum.random) |> Integer.to_string,
      state: [:open, :restored] |> Enum.random
    }
  end

  def to_string(%EvlSimulator.Event{command: command } = event) when command in ~w(609 610) do
    "#{event.command}#{event.zone |> String.pad_leading(3, "0")}"
  end

  # Private functions

  defp total_zones do
    Application.get_env(:evl_simulator, :total_zones, 6)
  end

  defp total_partitions do
    Application.get_env(:evl_simulator, :total_partitions, 1)
  end
end
