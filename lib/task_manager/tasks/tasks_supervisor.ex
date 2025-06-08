defmodule TaskManager.UserTaskSupervisor do
  use DynamicSupervisor

  def start_link(_opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_user_server(user_id) do
    child_spec = {TaskManager.UserTaskServer, user_id}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  rescue
    # GenServer already started
    ArgumentError -> :ignore
  end
end
