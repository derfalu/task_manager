defmodule TaskManagerWeb.AuthController do
  use TaskManagerWeb, :controller

  alias TaskManager.Accounts
  alias TaskManager.Auth.Token

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, token, _claims} = Token.generate_token(user)

        conn
        |> put_status(:created)
        |> json(%{
          message: "Пользователь успешно зарегистрирован",
          user: %{id: user.id, email: user.email, username: user.username, token: token}
        })

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  def login(conn, %{"user" => %{"login" => login, "password" => password}}) do
    case Accounts.authenticate_user(login, password) do
      {:ok, user} ->
        json(conn, %{message: "Успешный вход", user: %{id: user.id, email: user.email}})

      {:error, msg} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: msg})
    end
  end
end
