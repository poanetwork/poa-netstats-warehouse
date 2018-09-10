defmodule POABackend.Release.Tasks do

  @moduledoc """
  This module is needed when we create a release. We are using Mnesia locally so when we start create a release
  we have to create the Mnesia files there. In order to do that we have to run this `migrate/0` function.
  """

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  @repos [POABackend.Auth.Repo]

  def migrate() do
    start_services()

    run_migrations()
  end

  defp start_services do
    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for app
    IO.puts("Starting repos..")
    Enum.each(@repos, & &1.start_link(pool_size: 1))
  end

  defp run_migrations do
    Enum.each(@repos, &run_migrations_for/1)
  end

  defp run_migrations_for(repo) do
    case repo.__adapter__.storage_up(repo.config) do
      :ok ->
        IO.puts "The database for Mnesia has been created"
        :ok
      {:error, :already_up} ->
        IO.puts "The database for Mnesia has already been created"
        :ok
      {:error, error} ->
        IO.puts "The database for Mnesia couldn't be created: #{inspect error}"
        :error
    end
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running migrations for #{app}")
    migrations_path = migrations_path()
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  defp migrations_path(), do: Path.join([repo_path(), "migrations"])
  defp repo_path(), do: Path.join([priv_dir(), "auth"])
  defp priv_dir(), do: "#{:code.priv_dir(:poa_backend)}"
end