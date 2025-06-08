defmodule TaskManager.TasksServices do
  import Ecto.Query, warn: false
  alias TaskManager.Repo

  alias TaskManager.{TasksModel, CategoryModel}

  # -------- TASKS --------
  def list_tasks(user_id) do
    Repo.all(
      from t in TasksModel,
        join: c in assoc(t, :category),
        where: c.user_id == ^user_id
    )
  end

  def list_tasks_by_category(category_id) do
    Repo.all(
      from t in TasksModel,
        where: t.category_id == ^category_id
    )
  end

  def get_task(id), do: Repo.get(TasksModel, id)
  def get_task!(id), do: Repo.get!(TasksModel, id)

  def create_task(attrs \\ %{}) do
    %TasksModel{}
    |> TasksModel.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%TasksModel{} = task, attrs) do
    task
    |> TasksModel.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%TasksModel{} = task) do
    Repo.delete(task)
  end

  # -------- CATEGORIES --------
  def list_categories(user_id) do
    Repo.all(
      from c in CategoryModel, where: c.user_id == ^user_id
    )
  end

  def get_category(id), do: Repo.get(CategoryModel, id)

  def create_category(attrs \\ %{}) do
    %CategoryModel{}
    |> CategoryModel.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%CategoryModel{} = category, attrs) do
    category
    |> CategoryModel.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%CategoryModel{} = category) do
    Repo.delete(category)
  end
end
