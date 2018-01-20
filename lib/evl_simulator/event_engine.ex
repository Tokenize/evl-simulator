defmodule EvlSimulator.EventEngine do
  @moduledoc """
  This module defines the behaviour for an event engine.
  """

  @callback generate_event(code :: String.t()) :: EvlSimulator.Event
  @callback events() :: [String.t()]

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour EvlSimulator.EventEngine

      def child_spec(opts) do
        Logger.debug("#{__MODULE__}.start_link (#{inspect(opts)})")

        GenServer.start_link(__MODULE__, opts, [])
      end

      def init(opts) do
        Registry.register(Registry.EvlSimulator, "event_engines", __MODULE__)

        {:ok, opts, :hibernate}
      end

      @doc """
      Pause event generation by pausing the event engine's process.
      """
      def pause(pid) do
        Logger.debug("Pausing #{__MODULE__} event generation.")

        GenServer.cast(pid, :pause)
      end

      @doc """
      Resume event generation by resuming the event engine's process.
      """
      def resume(pid) do
        Logger.debug("Resuming #{__MODULE__} event generation.")

        GenServer.cast(pid, :resume)
      end

      @doc """
      An array of event codes that the event engine supports.
      """
      def events() do
        []
      end

      @doc """
      Return an Event based on the passed-in event code.
      """
      def generate_event(_event_code) do
        raise "Override me!"
      end

      # GenServer callbacks

      def handle_cast(:pause, state) do
        {:noreply, state, :hibernate}
      end

      def handle_cast(:resume, [event_interval: event_interval] = state) do
        {:noreply, state, event_interval}
      end

      def handle_info(:timeout, [event_interval: event_interval] = state) do
        Logger.debug("Generating #{__MODULE__} event.")

        events()
        |> Enum.random()
        |> generate_event
        |> EvlSimulator.Event.to_string()
        |> EvlSimulator.Connection.send()

        {:noreply, state, event_interval}
      end

      defoverridable generate_event: 1, events: 0
    end
  end
end
