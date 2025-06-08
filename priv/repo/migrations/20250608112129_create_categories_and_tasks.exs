defmodule TaskManager.Repo.Migrations.CreateCategoriesAndTasks do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :user_id, references(:users)
      timestamps()
    end

    create table(:tasks) do
      add :title, :string
      add :description, :text
      add :status, :string
      add :category_id, references(:categories)
      timestamps()
    end
  end
end
