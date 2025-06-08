defmodule TaskManager.CategoryModel do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :tasks]}

  schema "categories" do
    field :name, :string
    belongs_to :user, TaskManager.Accounts.User
    has_many :tasks, TaskManager.TasksModel
    timestamps()
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end

end
