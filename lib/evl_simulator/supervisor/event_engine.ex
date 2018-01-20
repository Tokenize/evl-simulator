defmodule EvlSimulator.Supervisor.EventEngine do
  use Supervisor

  def start_link(opts) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    [{Registry, keys: :duplicate, name: Registry.EvlSimulator}]
    |> Enum.concat(event_engines() |> Enum.map(fn {engine, opts} -> {engine, opts} end))
    |> Supervisor.init(strategy: :one_for_one)
  end

  # Private functions
  defp event_engines do
    Application.get_env(:evl_simulator, :event_engines, [])
  end
end
