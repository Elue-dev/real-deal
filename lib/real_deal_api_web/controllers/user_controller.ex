defmodule RealDealApiWeb.UserController do
  use RealDealApiWeb, :controller

  alias RealDealApi.Users
  alias RealDealApi.Users.User
  alias RealDealApi.Accounts

  import RealDealApiWeb.Auth.AuthorizedPlug

  plug :load_user when action in [:update, :delete]
  plug :is_authorized when action in [:update, :delete]

  action_fallback RealDealApiWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    account = Accounts.get_account!(user_params["account_id"])

    with {:ok, %User{} = user} <- Users.create_user(account, user_params) do
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.user

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn) do
    with {:ok, %User{}} <- Users.delete_user(conn.assigns.account.user) do
      send_resp(conn, :no_content, "")
    end
  end

  defp load_user(%{assigns: %{account: account}} = conn, _opts) do
    account = Accounts.get_account_expanded!(account.id)
    assign(conn, :user, account.user)
  end
end
