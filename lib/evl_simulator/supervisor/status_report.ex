defmodule EvlSimulator.Supervisor.StatusReport do
  use DynamicSupervisor

  def start_link(opts) do
    {:ok, _pid} = DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      restart: :transient
    )
  end

  def start_child(_opts \\ nil) do
    DynamicSupervisor.start_child(__MODULE__, EvlSimulator.Task.StatusReport)
  end
end
