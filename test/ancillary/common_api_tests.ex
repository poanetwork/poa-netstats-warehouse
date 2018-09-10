defmodule POABackend.Ancillary.CommonAPITest do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use ExUnit.Case
      alias POABackend.Auth
      alias POABackend.Ancillary.Utils

      @base_url "https://localhost:4003"
      @user "ferigis"
      @password "1234567890"
      @admin "admin1"
      @admin_pwd "password12345678"

      setup do
        Utils.clear_db()
        :ok = create_user()

        on_exit fn ->
          Utils.clear_db()
        end

        []
      end

      # ----------------------------------------
      # Internal functions
      # ----------------------------------------

      defp create_user(user \\ @user, password \\ @password) do
        {:ok, _user} = Auth.create_user(user, password)
        :ok
      end

      defp post(data, url, headers) do
        options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
        {:ok, response} = HTTPoison.post(url, data, headers, options)

        body = case response.body do
          "" ->
            :nobody
          _ ->
            {:ok, body} = Poison.decode(response.body)
            body
        end

        {response.status_code, body}
      end

      defp get(url, headers) do
        options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
        {:ok, response} = HTTPoison.get(url, headers, options)

        body = case response.body do
          "" ->
            :nobody
          _ ->
            {:ok, body} = Poison.decode(response.body)
            body
        end

        {response.status_code, body}
      end

      defp delete(url, headers) do
        options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
        {:ok, response} = HTTPoison.delete(url, headers, options)

        body = case response.body do
          "" ->
            :nobody
          _ ->
            {:ok, body} = Poison.decode(response.body)
            body
        end

        {response.status_code, body}
      end

      defp patch(data, url, headers) do
        options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
        {:ok, response} = HTTPoison.patch(url, data, headers, options)

        body = case response.body do
          "" ->
            :nobody
          _ ->
            {:ok, body} = Poison.decode(response.body)
            body
        end

        {response.status_code, body}
      end
    end
  end
end
