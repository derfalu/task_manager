defmodule TaskManagerWeb.CategoryController do
  use TaskManagerWeb, :controller

  alias TaskManager.UserTaskServer
  action_fallback TaskManagerWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user
    categories = UserTaskServer.get_categories(user.id)
    json(conn, categories)
  end

  def create(conn, %{"category" => category_params}) do
    user = conn.assigns.current_user
    case UserTaskServer.add_category(user.id, category_params) do
      {:ok, category} -> json(conn, category)
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: reason})
    end
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    user = conn.assigns.current_user
    case UserTaskServer.update_category(user.id, id, category_params) do
      {:ok, updated} -> json(conn, updated)
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: reason})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    IO.inspect(id, label: "Deleting category with ID")
    case UserTaskServer.delete_category(user.id, id) do
      :ok -> send_resp(conn, :no_content, "")
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: reason})
    end
  end
end
