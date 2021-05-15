defmodule EvlSimulator.Fuzzer.Connection do
  @moduledoc """
  This module fuzzes the connection response prior to sending it to the clients.
  """

  alias EvlSimulator.TPI

  require Logger
  use GenServer

  @default_interval 10_000

  def child_spec(opts) do
    %{
      id: __MODULE__,
      restart: :transient,
      start: {__MODULE__, :start_link, opts},
      type: :worker
    }
  end

  def start_link(_opts \\ []) do
    {_fuzzer, config} = Application.get_env(:evl_simulator, :fuzzer)
    interval = Keyword.get(config, :interval, @default_interval)

    GenServer.start_link(__MODULE__, %{interval: interval}, name: __MODULE__)
  end

  def init(%{interval: interval}) do
    {:ok, %{interval: interval, last_fuzzed_at: current_timestamp()}}
  end

  def encode(payload) do
    GenServer.call(__MODULE__, {:encode, payload})
  end

  # Callbacks

  def handle_call({:encode, payload}, _sender, %{last_fuzzed_at: nil} = state) do
    {:reply, TPI.encode(payload), %{state | last_fuzzed_at: current_timestamp()}}
  end

  def handle_call({:encode, payload}, _sender, state) do
    {encoded_payload, updated_state} = do_encode(payload, state, fuzz?(state))

    {:reply, encoded_payload, updated_state}
  end

  # Private functions

  defp do_encode(payload, state, _fuzz = true) do
    updated_state = %{state | last_fuzzed_at: current_timestamp}
    {TPI.encode(payload) |> String.graphemes() |> Enum.shuffle(), updated_state}
  end

  defp do_encode(payload, state, _fuzz) do
    {TPI.encode(payload), state}
  end

  defp fuzz?(%{last_fuzzed_at: last_fuzzed_at, interval: interval}) do
    (current_timestamp() - last_fuzzed_at) * 1000 >= interval
  end

  defp current_timestamp do
    DateTime.utc_now() |> DateTime.to_unix()
  end
end
