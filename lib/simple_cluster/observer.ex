defmodule SimpleCluster.Observer do
  use GenServer
  require Logger

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  @impl GenServer
  def init(state) do
    :net_kernel.monitor_nodes(true)
    {:ok, state}
  end

  @impl GenServer
  def handle_info({:nodedown, node}, state) do
    Logger.info("--- Node down: #{node}")
    {:noreply, state}
  end

  def handle_info({:nodeup, node}, state) do
    Logger.info("--- Node up: #{node}")
    {:noreply, state}
  end
end
