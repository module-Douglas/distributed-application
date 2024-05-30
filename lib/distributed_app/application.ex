defmodule DistributedApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    {port, _} = System.get_env("port", "4000") |> Integer.parse()
    children = [
      {Bandit, plug: DistributedApp.Router, scheme: :http, port: port},
      {Cache, []}
    ]
    opts = [strategy: :one_for_one, name: DistributedApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
