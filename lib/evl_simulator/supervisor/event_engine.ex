defmodule EvlSimulator.Supervisor.EventEngine do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init(_opts) do
    event_engines()
    |> Enum.map(fn ({engine, opts}) -> worker(engine, [opts]) end)
    |> supervise(strategy: :one_for_one)
  end

  # Private functions
  defp event_engines do
    Application.get_env(:evl_simulator, :event_engines, [])
  end
end
