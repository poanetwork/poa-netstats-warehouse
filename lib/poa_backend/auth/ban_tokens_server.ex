defmodule POABackend.Auth.BanTokensServer do
  @moduledoc false

  alias POABackend.Auth

  use GenServer

  @frequency 60 * 60 * 24 * 1000 # one day by default

  def start_link() do
    GenServer.start_link(__MODULE__, :noargs, name: __MODULE__)
  end

  def init(:noargs) do
    frequency = Application.get_env(:poa_backend, :purge_banned_tokens_freq, @frequency)

    set_purge_timer(frequency)

    {:ok, %{frequency: frequency}}
  end

  def handle_info(:purge, %{frequency: frequency} = state) do
    :ok = Auth.purge_banned_tokens()

    set_purge_timer(frequency)

    {:noreply, state}
  end

  defp set_purge_timer(frequency) do
    Process.send_after(self(), :purge, frequency)
  end
end