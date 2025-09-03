defmodule RealDealApiWeb.AccountJSON do
  alias RealDealApi.Accounts.Account
  alias RealDealApi.Users.User

  @doc """
  Renders a list of accounts.
  """
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  @doc """
  Renders a single account.
  """
  def show(%{account: account, token: token}) do
    %{
      data: data(account),
      token: token
    }
  end

  def show(%{account: account}) do
    %{data: data(account)}
  end

  def show_expanded(%{account: account, token: token}) do
    %{
      data: data_with_user(account),
      token: token
    }
  end

  def show_expanded(%{account: account}) do
    %{
      data: data_with_user(account)
    }
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      email: account.email
    }
  end

  defp data_with_user(%Account{} = account) do
    %{
      id: account.id,
      email: account.email,
      user: user_data(account.user)
    }
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      full_name: user.full_name,
      gender: user.gender,
      biography: user.biography
    }
  end

  defp user_data(nil), do: nil

  def error(%{message: message}) do
    %{
      error: message
    }
  end
end
