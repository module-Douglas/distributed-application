defmodule Cache do
  use GenServer
  require Logger

  def init(_) do
    {:ok, %{node: node()}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
    |> case do
      {:ok, pid} ->
        node1 = __MODULE__.get()[:node]
        Logger.info("Started cache at #{node1}")
        {:ok, pid}
      {:error, _} ->
        node1 = __MODULE__.get()[:node]
        Logger.info("Already started at: #{node1}")
        {:ok, nil}
    end
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end
  def handle_cast(:sync, state) do
    :rpc.multicall(Node.list(), __MODULE__, :put_state, [state])
    {:noreply, state}
  end
  def handle_cast({:put_state, state}, _state) do
    {:noreply, state}
  end

  def put(key, value), do: GenServer.cast({:global, __MODULE__}, {:put, key, value})
  def put_state(state), do: GenServer.cast({:global, __MODULE__}, {:put_state, state})
  def get, do: GenServer.call({:global, __MODULE__}, :get)
  def sync, do: GenServer.cast({:global, __MODULE__}, :sync)
end
