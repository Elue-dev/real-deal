defmodule RealDealApiWeb.AccountController do
  use RealDealApiWeb, :controller

  alias RealDealApi.{Accounts, Accounts.Account, Users, Users.User}
  alias RealDealApiWeb.{Auth.Guardian, Auth.ErrorResponse}
  
  plug :is_authorized_account when action in [:update, :delete]

  action_fallback RealDealApiWeb.FallbackController

  # defp is_authorized_account(conn, _params) do
  #   if conn.assigns.account.id == conn.params["id"] do
  #     conn
  #   else
  #     raise ErrorResponse.Forbidden
  #   end
  # end
  
  defp is_authorized_account(%{params: %{"id" => id}, assigns: %{account: %{id: id}}} = conn, _params), 
  do: conn
  
  defp is_authorized_account(_conn, _params),
  do: raise ErrorResponse.Forbidden

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(account),
         {:ok, %User{} = _user} <- Users.create_user(account, account_params) do
      conn
      |> put_status(:created)
      |> render(:show, account: account, token: token)
    end
  end


  def login(conn, %{"email" => email, "hash_password" => password}) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:show, account: account, token: token)

      {:error, _reason} ->
      {:error, :unauthorized}
    end
  end

  def login(_conn, _params) do
    {:error, :bad_request}
  end


  def logout(conn, %{}) do
    account = conn.assigns[:account]
    token = conn |> Guardian.Plug.current_token()
    token |> Guardian.revoke()

    conn
    |> Plug.Conn.clear_session()
    |> put_status(:ok)
    |> json(%{message: "logout successful"})
  end

  # def me(conn, %{"id" => id}) do
  #   account = Accounts.get_account!(id)
  #   render(conn, :show, account: account)
  # end

  def me(conn, _params) do
    render(conn, :show, account: conn.assigns.account)
  end
  
def update(conn, %{"account" => account_params}) do
  account = conn.assigns.account

  with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
    render(conn, :show, account: account)
  end
end

def delete(conn, _params) do
  account = conn.assigns.account

  with {:ok, %Account{}} <- Accounts.delete_account(account) do
    send_resp(conn, :no_content, "")
  end
end

end
