defmodule POABackend.Receivers.Repo.Migrations.CreateEthStats do
  use Ecto.Migration

  def change do
    create table(:eth_stats, primary_key: false) do
      add :date, :naive_datetime, primary_key: true
      add :agent_id, :string, primary_key: true
      add :active, :boolean
      add :mining, :boolean
      add :hashrate, :integer
      add :peers, :integer
      add :gas_price, :integer
      add :current_block, :string
      add :highest_block, :string
      add :starting_block, :string
    end
  end
end
