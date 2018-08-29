defmodule POABackend.Auth.Repo.Migrations.CreateBannedTokens do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:banned_tokens, primary_key: false) do
      add :token, :string, primary_key: true
      add :expires, :integer

      timestamps()
    end
  end
end
