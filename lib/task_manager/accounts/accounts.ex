defmodule TaskManager.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TaskManager.Repo

  alias TaskManager.UserModel

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(UserModel)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(UserModel, id)

  @doc """
  Creates a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
def register_user(attrs) do
  Repo.transaction(fn ->
    with {:ok, user} <- Repo.insert(UserModel.registration_changeset(%UserModel{}, attrs)) do
      # Создание дефолтной категории
      %TaskManager.CategoryModel{}
      |> TaskManager.CategoryModel.changeset(%{
        name: "Основные",
        user_id: user.id
      })
      |> Repo.insert!()

      # Запуск GenServer (можно через Supervisor)
      TaskManager.UserTaskSupervisor.start_user_server(user.id)

      user
    else
      {:error, _} = err -> Repo.rollback(err)
    end
  end)
end



  def authenticate_user(login, password) do
    user = Repo.get_by(UserModel, email: login) || Repo.get_by(UserModel, username: login)

    case user do
      nil -> {:error, "user_not_found"}
      _ ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, "invalid_password"}
        end
    end
  end
  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%UserModel{} = user, attrs) do
    user
    |> UserModel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%UserModel{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%UserModel{} = user, attrs \\ %{}) do
    UserModel.changeset(user, attrs)
  end
end
