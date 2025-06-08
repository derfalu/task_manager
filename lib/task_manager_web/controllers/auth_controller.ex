defmodule TaskManagerWeb.AuthController do
  use TaskManagerWeb, :controller

  alias TaskManager.{Accounts, TasksServices, UserTaskSupervisor, UserTaskServer}
  alias TaskManager.Auth.Token

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        TasksServices.create_category(%{"name" => "Основные", "user_id" => user.id})
        UserTaskSupervisor.start_user_server(user.id)
        state = UserTaskServer.get_state(user.id)
        {:ok, token, _claims} = Token.generate_token(user)

        conn
        |> put_status(:created)
        |> json(%{
          message: "Пользователь успешно зарегистрирован",
          user: %{id: user.id, email: user.email, username: user.username, token: token},
          data: state
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
        case UserTaskSupervisor.start_user_server(user.id) do
          {:ok, _pid} ->
            # Ожидаем, пока сервер полностью инициализируется
            GenServer.call(UserTaskServer.via_tuple(user.id), :ping)

          {:error, {:already_started, _pid}} ->
            :ok
        end

        state = UserTaskServer.get_state(user.id)
        {:ok, token, _claims} = Token.generate_token(user)

        json(conn, %{
          message: "Успешный вход",
          user: %{id: user.id, email: user.email, username: user.username, token: token},
          data: state
        })

      {:error, msg} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: msg})
    end
  end
end
