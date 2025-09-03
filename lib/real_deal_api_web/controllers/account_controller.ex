defmodule RealDealApiWeb.AccountController do
  use RealDealApiWeb, :controller

  alias RealDealApi.{Accounts, Accounts.Account, Users, Users.User}
  alias RealDealApiWeb.Auth.Guardian

  import RealDealApiWeb.Auth.AuthorizedPlug

  plug :is_authorized when action in [:update, :delete]

  action_fallback RealDealApiWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, %User{} = _user} <- Users.create_user(account, account_params) do
      authorize_account(conn, account.email, account_params["hash_password"])
    end
  end

  def login(conn, %{"email" => email, "hash_password" => password}) do
    authorize_account(conn, email, password)
  end

  def login(_conn, _params) do
    {:error, :bad_request}
  end

  defp authorize_account(conn, email, password) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        expanded_account = Accounts.get_account_expanded!(account.id)

        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:show_expanded, account: expanded_account, token: token)

      {:error, _reason} ->
        {:error, :unauthorized}
    end
  end

  def refresh_session(conn, %{}) do
    token = conn |> Guardian.Plug.current_token()
    {:ok, account, new_token} = Guardian.authenticate(token)

    conn
    |> Plug.Conn.put_session(:account_id, account.id)
    |> put_status(:ok)
    |> render(:show, account: account, token: new_token)
  end

  def logout(conn, %{}) do
    _account = conn.assigns[:account]
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

  # def me(conn, _params) do
  #   render(conn, :show, account: conn.assigns.account)
  # end

  def me(%{assigns: %{account: account}} = conn, _params) do
    expanded_account = Accounts.get_account_expanded!(account.id)
    render(conn, :show_expanded, account: expanded_account)
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
