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
    post "/accounts/create", AccountController, :create
    post "/accounts/login", AccountController, :login
  end

scope "/api", RealDealApiWeb do
   pipe_through [:api, :auth]

   get "/me", AccountController, :me
   get "/accounts/logout", AccountController, :logout
   patch "/accounts/:id", AccountController, :update
   delete "/accounts/:id", AccountController, :delete
end

end
