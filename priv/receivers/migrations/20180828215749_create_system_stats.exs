defmodule POABackend.Receivers.Repo.Migrations.CreateSystemStats do
  use Ecto.Migration

  def change do
    create table(:system_stats, primary_key: false) do
      add :date, :naive_datetime, primary_key: true
      add :agent_id, :string, primary_key: true
      add :cpu_load, :float
      add :disk_usage, :integer
      add :memory_usage, :float
    end
  end
end
