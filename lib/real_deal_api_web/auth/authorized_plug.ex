defmodule RealDealApiWeb.Auth.AuthorizedPlug do
  alias(RealDealApiWeb.Auth.ErrorResponse)

  # def is_authorized(conn, _params) do
  #   if conn.assigns.account.id == conn.params["id"] do
  #     conn
  #   else
  #     raise ErrorResponse.Forbidden
  #   end
  # end

  def is_authorized(
        %{params: %{"id" => id}, assigns: %{account: %{id: id}}} = conn,
        _params
      ),
      do: conn

  def is_authorized(%{assigns: %{user: _user}} = conn, _params), do: conn

  def is_authorized(_conn, _params),
    do: raise(ErrorResponse.Forbidden)
end
