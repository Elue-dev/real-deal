defmodule RealDealApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use RealDealApiWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: RealDealApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: RealDealApiWeb.ErrorHTML, json: RealDealApiWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "invalid credentials"})
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "invalid parameters"})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Forbidden"})
  end

  def call(conn, {:error, :invalid_password}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "invalid password"})
  end

  def call(conn, {:error, :missing_password}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "password required"})
  end

  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "Internal server error"})
  end
end
