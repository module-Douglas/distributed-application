defmodule DistributedApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    {port, _} = System.get_env("port", "4000") |> Integer.parse()
    children = [
      {Bandit, plug: DistributedApp.Router, scheme: :http, port: port},
      {CacheSupervisor, []},
      {Cluster.Supervisor, [[
        distributed_app: [
          strategy: Cluster.Strategy.Epmd,
          #config: [hosts: [:"__1@douglas-systemproductname", :"__2@douglas-systemproductname"]],
          config: [hosts: [:"app@api_1", :"app@api_2", :"app@api_3"]]
        ]
      ], [name: DistributedApp.ClusterSupervisor]]}
    ]

    opts = [strategy: :one_for_one, name: DistributedApp.Supervisor]
    Supervisor.start_link(children, opts)

    :timer.sleep(1000)
    CacheSupervisor.start()
    spawn fn ->
      :net_kernel.monitor_nodes(true, %{nodedown_reason: true})
    end
  end

  def loop do
    receive do
      {:nodedown, _host, _message} ->
        :timer.sleep(round(:rand.uniform() * 1000))
        if !is_pid(:global.whereis_name(Cache)), do: CacheSupervisor.start()
      _ -> nil
    end
    loop()
  end
end
