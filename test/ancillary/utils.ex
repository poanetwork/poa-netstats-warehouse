defmodule POABackend.Ancillary.Utils do
  @moduledoc false

  def clear_db do
    :mnesia.clear_table(:users)
    :mnesia.clear_table(:banned_tokens)

    truncate(POABackend.Receivers.Models.EthStats)
  end

  defp truncate(schema) do
    table_name = schema.__schema__(:source)
    POABackend.Receivers.Repo.query("TRUNCATE #{table_name}", [])
    :ok
  end

end