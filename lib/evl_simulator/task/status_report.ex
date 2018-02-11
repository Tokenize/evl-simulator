defmodule EvlSimulator.Task.StatusReport do
  @moduledoc """
  This module emits activity and system events in quick succession to simulate a dump
  of all zone and partition statuses.
  """

  require Logger
  use GenServer

  @time_to_live 5000

  def child_spec(opts) do
    %{
      id: __MODULE__,
      restart: :transient,
      start: {__MODULE__, :start_link, opts},
      type: :worker
    }
  end

  def start_link(_opts \\ nil) do
    Logger.debug("#{__MODULE__}.start_link")

    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    engine_pids =
      [
        EvlSimulator.EventEngine.Activity.start_link(event_interval: 100),
        EvlSimulator.EventEngine.System.start_link(event_interval: 500)
      ]
      |> Enum.map(fn {:ok, pid} -> pid end)

    {:ok, engine_pids, @time_to_live}
  end

  # GenServer Callbacks

  def handle_info(:timeout, engine_pids) do
    {:stop, :normal, engine_pids}
  end

  def terminate(_reason, engine_pids) do
    engine_pids
    |> Enum.each(fn pid -> GenServer.stop(pid, :normal) end)
  end
end
