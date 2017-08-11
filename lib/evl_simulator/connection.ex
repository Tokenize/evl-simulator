defmodule EvlSimulator.Connection do
  @moduledoc """
  This module wraps a TCP connection and handles connecting, disconnecting, sending and
  receiving commands to EVL clients.
  """

  require Logger
  use GenServer

  def start_link do
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
    Logger.debug "Receiving Network Login request"

    {:ok, decoded_payload} = EvlSimulator.TPI.decode(payload)

    :ok = do_acknowledge(socket, decoded_payload)
    :ok = do_login_response(socket, decoded_payload)

    {:noreply, state}
  end

  def handle_info({:tcp, socket, payload}, state) do
    Logger.info("We got: #{inspect payload}")

    :ok = do_acknowledge(socket, payload)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("TCP Socket closed.")

    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, socket, reason}, state) do
    Logger.error("TCP Socket #{inspect socket} error: #{reason}")

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

  # Private functions

  defp do_request_login(client_socket) do
    "5053" |> do_send(client_socket)
  end

  defp do_login_response(client_socket, payload) do
    password = EvlSimulator.TPI.data_part(payload)
    correct_password = Application.get_env(:evl_simulator, :password)

    status = case password do
      ^correct_password -> "1"
      _ -> "0"
    end

    "505#{status}" |> do_send(client_socket)
  end

  defp do_acknowledge(client_socket, payload) do
    "500#{EvlSimulator.TPI.command_part(payload)}" |> do_send(client_socket)
  end

  defp do_send(payload, client_socket) do
    encoded_payload = EvlSimulator.TPI.encode(payload)
    :gen_tcp.send(client_socket, encoded_payload)
  end
end
