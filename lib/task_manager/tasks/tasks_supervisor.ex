defmodule TaskManager.UserTaskSupervisor do
  use DynamicSupervisor

  @doc """
  Начинает динамический супервизор для управления задачами пользователей.
  Этот супервизор будет управлять процессами, связанными с задачами каждого пользователя.
  """
  def start_link(_opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Инициализирует супервизор с стратегией "один за одного".
  Эта стратегия означает, что если один из процессов завершится с ошибкой,
  он будет перезапущен, а остальные процессы останутся активными.
  """
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Запускает сервер задач для указанного пользователя.
  Если сервер уже существует, будет выброшено исключение `ArgumentError`, которое мы игнорируем.
  """
  def start_user_server(user_id) do
    child_spec = {TaskManager.UserTaskServer, user_id}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  rescue
    ArgumentError -> :ignore
  end
end
