defmodule POABackend.Auth.Guardian do
  @moduledoc false
  use Guardian, otp_app: :poa_backend

  alias POABackend.Auth

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.user)}
  end

  def resource_from_claims(%{"sub" => user}) do
    case Auth.get_user(user) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end