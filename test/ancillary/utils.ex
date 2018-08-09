defmodule POABackend.Ancillary.Utils do
  @moduledoc false

  def clear_db do
    :mnesia.clear_table(:users)
    :mnesia.clear_table(:banned_tokens)
  end

end