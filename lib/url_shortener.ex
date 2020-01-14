defmodule UrlShortener do
  @moduledoc """
  Documentation for UrlShortener.
  """
  use GenServer

  # GenServer Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  def shorten(pid, url) do
    GenServer.call(pid, {:shorten, url})
  end

  def get(pid, md5) do
    GenServer.call(pid, {:get, md5})
  end

  def flush(pid) do
    GenServer.cast(pid, :flush)
  end

  def count(pid) do
    GenServer.call(pid, :count)
  end

  defp md5(url) do
    :crypto.hash(:md5, url) |> Base.encode16(case: :lower)
  end

  # GenServer Callbacks
  @impl true
  def init(:ok) do
    # set the state of the process to an empty map.
    {:ok, %{}}
  end

  @impl true
  def handle_cast(:stop, state) do
    # Casts are asynchronous: the client doesn't expect a response back
    # Expected msg format: :stop, reason, new_state
    {:stop, :normal, state}
  end

  @impl true
  def handle_cast(:flush, _state) do
    {:noreply, %{}}
  end

  @impl true
  def handle_call({:shorten, url}, _from, state) do
    # Calls are synchronous: the client expects a response back
    short = md5(url)
    # 2nd arg -> reply sent to client. 3rd arg - new state
    {:reply, short, Map.put(state, short, url)}
  end

  @impl true
  def handle_call({:get, md5}, _from, state) do
    {:reply, Map.get(state, md5), state}
  end

  @impl true
  def handle_call(:count, _from, state) do
    count = Map.keys(state) |> Enum.count()
    {:reply, count, state}
  end
end
