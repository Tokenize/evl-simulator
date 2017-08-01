defmodule EvlSimulator.Supervisor do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    child_processes = [
      worker(EvlSimulator.Connection, [])
    ]

    supervise(child_processes, strategy: :one_for_one)
  end
end
