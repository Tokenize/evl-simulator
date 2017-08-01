defmodule EvlSimulator do
  @moduledoc """
  Documentation for EvlSimulator.
  """

  require Logger
  use Application

  def start(_type, _args) do
    Logger.info("Starting EvlSimulator...")

    EvlSimulator.Supervisor.start_link
  end

  def stop(_state) do
    Logger.info("Stopping EvlSimulator...")
  end
end
