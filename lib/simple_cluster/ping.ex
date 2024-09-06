defmodule SimpleCluster.Ping do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def ping do
    Node.list()
    |> Enum.map(&GenServer.call({__MODULE__, &1}, :ping))
    |> Logger.info()
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  @impl GenServer
  def handle_call(:ping, from, state) do
    Logger.info("--- Receiving ping from #{inspect(from)}")
    {:reply, {:ok, node(), :pong}, state}
  end
end
