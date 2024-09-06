defmodule SimpleCluster.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SimpleCluster.Observer,
      SimpleCluster.Ping,
      SimpleCluster.Send
    ]

    opts = [strategy: :one_for_one, name: SimpleCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
