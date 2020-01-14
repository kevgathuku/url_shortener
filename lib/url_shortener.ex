defmodule UrlShortener do
  @moduledoc """
  Documentation for UrlShortener.
  """

  @doc """
  Hello world.

  ## Examples

      iex> UrlShortener.hello()
      :world

  """
  def start do
    # Spawns the given function (2nd arg) from the given module (1st arg)
    # passing it the given args (3rd arg) and returns its PID.
    spawn(__MODULE__, :loop, [%{}])
  end

  def loop(state) do
    receive do
      {:stop, caller} ->
        send(caller, "Shutting down.")

      {:shorten, url, caller} ->
        url_md5 = md5(url)
        new_state = Map.put(state, url_md5, url)
        send(caller, url_md5)
        loop(new_state)

      {:get, md5, caller} ->
        send(caller, Map.fetch(state, md5))
        loop(state)

      :flush ->
        loop(%{})

      _ ->
        loop(state)
    end
  end

  defp md5(url) do
    :crypto.hash(:md5, url) |> Base.encode16(case: :lower)
  end
end
