defmodule RealDealApiWeb.Auth.SetAccount do
  import Plug.Conn
  alias RealDealApiWeb.Auth.ErrorResponse
  alias RealDealApi.Accounts

  def init(_opts) do

  end

  def call(conn, _opts) do
    if conn.assigns[:account], do: (conn |> halt())

    account_id =  conn |> get_session(:account_id)

    if account_id == nil, do: raise ErrorResponse.Unauthorized

    account = Accounts.get_account!(account_id)
    cond do
      account_id && account -> conn |> assign(:account, account)
      true ->  conn |> assign(:account, nil)
   end
  end
end
