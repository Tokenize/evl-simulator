defmodule EvlSimulator.Connection do
  @moduledoc """
  This module wraps a TCP connection and handles connecting, disconnecting, sending and
  receiving commands to EVL clients.
  """

  require Logger
  use GenServer

  def start_link do
    port = Application.get_env(:evl_simulator, :port)
    GenServer.start_link(__MODULE__, %{port: port}, [])
  end

  def init(state) do
    {:ok, state, 0}
  end

  def handle_info({:tcp, socket, payload}, state) do
    Logger.info("We got: #{inspect payload}")
    :gen_tcp.send(socket, "echo: #{payload}\n")

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, _state) do
    Logger.info("TCP Socket closed.")

    {:stop, :normal}
  end

  def handle_info({:tcp_error, socket, reason}, _state) do
    Logger.error("TCP Socket #{inspect socket} error: #{reason}")

    {:stop, :normal}
  end

  def handle_info(:timeout, state) do
    opts = [:binary, active: true, reuseaddr: true, packet: :line]
    {:ok, listening_socket} = :gen_tcp.listen(state.port, opts)
    {:ok, client_socket} = :gen_tcp.accept(listening_socket)

    {:noreply, %{listening_socket: listening_socket, client_socket: client_socket}}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end
end
