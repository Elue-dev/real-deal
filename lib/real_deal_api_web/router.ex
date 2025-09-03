defmodule RealDealApiWeb.Router do
  use RealDealApiWeb, :router
  use Plug.ErrorHandler

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn
    |> json(%{errors: message})
    |> halt()
  end

  def handle_errors(conn, %{reason: %{message: message}}) do
    conn
    |> json(%{errors: message})
    |> halt()
  end

  def handle_errors(conn, %{reason: reason}) do
    conn
    |> put_status(:internal_server_error)
    |> Phoenix.Controller.json(%{errors: inspect(reason)})
    |> halt()
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :auth do
    plug RealDealApiWeb.Auth.Pipeline
    plug RealDealApiWeb.Auth.SetAccount
  end

  scope "/api", RealDealApiWeb do
    pipe_through :api

    get "/", DefaultController, :index
    post "/accounts/register", AccountController, :create
    post "/accounts/login", AccountController, :login
  end

  scope "/api", RealDealApiWeb do
    pipe_through [:api, :auth]

    get "/me", AccountController, :me
    get "/accounts/logout", AccountController, :logout
    get "/accounts/refresh_session", AccountController, :refresh_session
    patch "/accounts", AccountController, :update
    delete "/accounts", AccountController, :delete
    patch "/users", UserController, :update
    get "/users", UserController, :index
  end
end
