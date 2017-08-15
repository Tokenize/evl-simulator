defmodule EvlSimulator.Supervisor.EventEngine do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init(_opts) do
    child_processes = [
      worker(EvlSimulator.EventEngine.Activity, []),
      worker(EvlSimulator.EventEngine.System, []),
    ]

    supervise(child_processes, strategy: :one_for_one)
  end
end
