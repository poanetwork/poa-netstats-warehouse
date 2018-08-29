defmodule POABackend.Receivers.Models.EthStats do
  use Ecto.Schema

  @moduledoc false

  @primary_key false

  schema "eth_stats" do
    field :date, :naive_datetime, primary_key: true
    field :agent_id, :string, primary_key: true
    field :active, :boolean
    field :mining, :boolean
    field :hashrate, :integer
    field :peers, :integer
    field :gas_price, :integer
    field :current_block, :string
    field :highest_block, :string
    field :starting_block, :string
  end

  @type t :: %__MODULE__{
    date: NaiveDateTime.t,
    agent_id: String.t,
    active: Boolean.t,
    mining: Boolean.t,
    hashrate: Integer.t,
    peers: Integer.t,
    gas_price: Integer.t,
    current_block: String.t,
    highest_block: String.t,
    starting_block: String.t
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

  @spec active(__MODULE__.t, Boolean.t) :: __MODULE__.t
  def active(eth_stats, active) do
    %__MODULE__{eth_stats | active: active}
  end

  @spec mining(__MODULE__.t, Boolean.t) :: __MODULE__.t
  def mining(eth_stats, mining) do
    %__MODULE__{eth_stats | mining: mining}
  end

  @spec hashrate(__MODULE__.t, Integer.t) :: __MODULE__.t
  def hashrate(eth_stats, hashrate) do
    %__MODULE__{eth_stats | hashrate: hashrate}
  end

  @spec peers(__MODULE__.t, Integer.t) :: __MODULE__.t
  def peers(eth_stats, peers) do
    %__MODULE__{eth_stats | peers: peers}
  end

  @spec gas_price(__MODULE__.t, Integer.t) :: __MODULE__.t
  def gas_price(eth_stats, gas_price) do
    %__MODULE__{eth_stats | gas_price: gas_price}
  end

  @spec current_block(__MODULE__.t, String.t) :: __MODULE__.t
  def current_block(eth_stats, current_block) do
    %__MODULE__{eth_stats | current_block: current_block}
  end

  @spec highest_block(__MODULE__.t, String.t) :: __MODULE__.t
  def highest_block(eth_stats, highest_block) do
    %__MODULE__{eth_stats | highest_block: highest_block}
  end

  @spec starting_block(__MODULE__.t, String.t) :: __MODULE__.t
  def starting_block(eth_stats, starting_block) do
    %__MODULE__{eth_stats | starting_block: starting_block}
  end

end