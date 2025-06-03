defmodule TaskManagerWeb.SessionController do
  use TaskManagerWeb, :controller

  alias TaskManager.Accounts

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{message: "User registered successfully", user: %{id: user.id, email: user.email, username: user.username}})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: "/")
  end

end
