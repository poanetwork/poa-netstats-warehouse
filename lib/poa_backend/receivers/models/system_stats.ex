defmodule POABackend.Receivers.Models.SystemStats do
  use Ecto.Schema

  @moduledoc false

  @primary_key false

  schema "system_stats" do
    field :date, :naive_datetime, primary_key: true
    field :agent_id, :string, primary_key: true
    field :cpu_load, :float
    field :disk_usage, :integer
    field :memory_usage, :float
  end

  @type t :: %__MODULE__{
    date: NaiveDateTime.t,
    agent_id: String.t,
    cpu_load: Float.t,
    disk_usage: Float.t,
    memory_usage: Float.t
  }

  @spec new() :: __MODULE__.t
  def new do
    %__MODULE__{}
  end

  @spec date(__MODULE__.t, NaiveDateTime.t) :: __MODULE__.t
  def date(eth_stats, date) do
    %__MODULE__{eth_stats | date: date}
  end

  @spec agent_id(__MODULE__.t, String.t) :: __MODULE__.t
  def agent_id(eth_stats, agent_id) do
    %__MODULE__{eth_stats | agent_id: agent_id}
  end

  @spec cpu_load(__MODULE__.t, Float.t) :: __MODULE__.t
  def cpu_load(eth_stats, cpu_load) do
    %__MODULE__{eth_stats | cpu_load: cpu_load}
  end

  @spec disk_usage(__MODULE__.t, Float.t) :: __MODULE__.t
  def disk_usage(eth_stats, disk_usage) do
    %__MODULE__{eth_stats | disk_usage: disk_usage}
  end

  @spec memory_usage(__MODULE__.t, Float.t) :: __MODULE__.t
  def memory_usage(eth_stats, memory_usage) do
    %__MODULE__{eth_stats | memory_usage: memory_usage}
  end

end