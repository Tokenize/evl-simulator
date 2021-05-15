defmodule EvlSimulator.Connection do
  @moduledoc """
  This module wraps a TCP connection and handles connecting, disconnecting, sending and
  receiving commands to EVL clients.
  """

  require Logger
  use GenServer

  def child_spec(opts) do
    %{
      id: __MODULE__,
      restart: :permanent,
      start: {__MODULE__, :start_link, opts},
      type: :worker
    }
  end

  def start_link(_opts \\ []) do
    port = Application.get_env(:evl_simulator, :port)
    GenServer.start_link(__MODULE__, %{port: port}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state, 0}
  end

  def send(payload) do
    GenServer.cast(__MODULE__, {:send, payload})
  end

  # GenServer callbacks

  def handle_cast({:send, payload}, state) do
    payload |> do_send(state.client_socket)

    {:noreply, state}
  end

  def handle_info({:tcp, socket, "005" <> _trailer = payload}, state) do
    Logger.debug("Receiving Network Login request")

    {:ok, decoded_payload} = EvlSimulator.TPI.decode(payload)

    :ok = do_acknowledge(socket, decoded_payload)
    status = do_login_response(socket, decoded_payload)

    case status do
      :ok ->
        do_resume_event_engines()
        {:noreply, state}

      _ ->
        {:stop, {:shutdown, :authentication_failure}, state}
    end
  end

  def handle_info({:tcp, socket, "001" <> _trailer = payload}, state) do
    Logger.debug("Receiving Status Report request")

    {:ok, decoded_payload} = EvlSimulator.TPI.decode(payload)

    :ok = do_acknowledge(socket, decoded_payload)
    EvlSimulator.Supervisor.StatusReport.start_child()
    do_resume_event_engines()

    {:noreply, state}
  end

  def handle_info({:tcp, socket, payload}, state) do
    Logger.info("We got: #{inspect(payload)}")

    :ok = do_acknowledge(socket, payload)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("TCP Socket closed.")

    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, socket, reason}, state) do
    Logger.error("TCP Socket #{inspect(socket)} error: #{reason}")

    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    opts = [:binary, active: true, reuseaddr: true, packet: :line]
    {:ok, listening_socket} = :gen_tcp.listen(state.port, opts)
    {:ok, client_socket} = :gen_tcp.accept(listening_socket)

    :ok = do_request_login(client_socket)

    {:noreply, %{listening_socket: listening_socket, client_socket: client_socket}}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  def terminate(_reason, _state) do
    do_pause_event_engines()
  end

  # Private functions

  defp do_request_login(client_socket) do
    "5053" |> do_send(client_socket)
  end

  defp do_login_response(client_socket, payload) do
    password = EvlSimulator.TPI.data_part(payload)
    correct_password = Application.get_env(:evl_simulator, :password)

    {action, status} =
      case password do
        ^correct_password ->
          Logger.debug("Authentication successful.")
          {:ok, "1"}

        _ ->
          Logger.debug("Authentication unsucessful.")
          {:error, "0"}
      end

    :ok = "505#{status}" |> do_send(client_socket)

    action
  end

  defp do_acknowledge(client_socket, payload) do
    "500#{EvlSimulator.TPI.command_part(payload)}" |> do_send(client_socket)
  end

  defp do_send(payload, client_socket) do
    fuzzer_config = Application.get_env(:evl_simulator, :fuzzer)
    encoded_payload = do_prepare_payload(payload, fuzzer_config)

    :gen_tcp.send(client_socket, encoded_payload)
  end

  defp do_prepare_payload(payload, fuzzer_config) when is_nil(fuzzer_config) do
    payload
    |> EvlSimulator.TPI.encode()
  end

  defp do_prepare_payload(payload, fuzzer_config) do
    {fuzzer, _interval} = fuzzer_config

    payload
    |> fuzzer.encode
  end

  defp do_resume_event_engines do
    Registry.dispatch(Registry.EvlSimulator, "event_engines", fn engines ->
      for {pid, module} <- engines, do: apply(module, :resume, [pid])
    end)
  end

  defp do_pause_event_engines do
    Registry.dispatch(Registry.EvlSimulator, "event_engines", fn engines ->
      for {pid, module} <- engines, do: apply(module, :pause, [pid])
    end)
  end
end
