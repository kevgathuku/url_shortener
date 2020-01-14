defmodule UrlShortener do
  @moduledoc """
  Documentation for UrlShortener.
  """
  use Agent

  def start do
    # Init with an empty map as the initial state
    Agent.start_link(fn -> %{} end)
  end

  def get(agent, md5) do
    Agent.get(agent, &Map.fetch(&1, md5))
  end

  def shorten(agent, url) do
    url_md5 = md5(url)
    Agent.update(agent, fn state -> Map.put(state, url_md5, url) end)
  end

  def stop(agent) do
    Agent.stop(agent)
    # send(caller, "Shutting down")
  end

  defp md5(url) do
    :crypto.hash(:md5, url) |> Base.encode16(case: :lower)
  end
end
