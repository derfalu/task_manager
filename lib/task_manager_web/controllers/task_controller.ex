defmodule TaskManagerWeb.TaskController do
  use TaskManagerWeb, :controller

  alias TaskManager.{TasksServices, UserTaskServer}

  action_fallback TaskManagerWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user
    tasks = UserTaskServer.get_state(user.id)
    json(conn, tasks)
  end

  def create(conn, %{"task" => task_params}) do
    user = conn.assigns.current_user
    case UserTaskServer.add_task(user.id, task_params) do
      {:ok, task} -> json(conn, task)
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: reason})
    end
  end

  def show(conn, %{"id" => id}) do
    case TasksServices.get_task!(id) do
      task -> json(conn, task)
    end
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    user = conn.assigns.current_user
    case TasksServices.get_task!(id) do
      task ->
        case UserTaskServer.update_task(user.id, id, task_params) do
          {:ok, updated} -> json(conn, updated)
          {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: reason})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case TasksServices.get_task!(id) do
      task ->
        case UserTaskServer.delete_task(user.id, id) do
          :ok -> send_resp(conn, :no_content, "")
          {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: reason})
        end
    end
  end
end
