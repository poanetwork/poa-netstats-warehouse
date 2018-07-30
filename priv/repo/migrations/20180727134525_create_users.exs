defmodule POABackend.Auth.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:users, primary_key: false) do
      add :user, :string, primary_key: true
      add :password_hash, :string
      add :active, :boolean, default: true

      timestamps()
    end
  end
end
