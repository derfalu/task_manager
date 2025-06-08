defmodule TaskManager.TasksModel do
  use Ecto.Schema
  import Ecto.Changeset
  
  @derive {Jason.Encoder, only: [:id, :title, :description, :status, :category_id]}

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "new"

    belongs_to :category, TaskManager.Tasks.Category

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :category_id])
    |> validate_required([:title, :status, :category_id])
    |> validate_inclusion(:status, ["new", "in-progress", "completed"])
  end

end
