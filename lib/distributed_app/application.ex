defmodule DistributedApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit, plug: DistributedApp.Router, scheme: :http},
      {Cache, []}
    ]
    opts = [strategy: :one_for_one, name: DistributedApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
