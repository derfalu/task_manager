defmodule TaskManager.UserTaskServer do
  use GenServer
  alias TaskManager.TasksServices

  # ===== PUBLIC API =====

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via_tuple(user_id))
  end

  def via_tuple(user_id) do
    {:via, Registry, {TaskManager.Registry, user_id}}
  end

  def get_state(user_id) do
    GenServer.call(via_tuple(user_id), :get_state)
  end

  def add_category(user_id, attrs) do
    GenServer.call(via_tuple(user_id), {:add_category, attrs})
  end

  def update_category(user_id, category_id, attrs) do
    GenServer.call(via_tuple(user_id), {:update_category, category_id, attrs})
  end

  def delete_category(user_id, category_id) do
    GenServer.call(via_tuple(user_id), {:delete_category, category_id})
  end

  def add_task(user_id, attrs) do
    GenServer.call(via_tuple(user_id), {:add_task, attrs})
  end

  def update_task(user_id, task_id, attrs) do
    GenServer.call(via_tuple(user_id), {:update_task, task_id, attrs})
  end

  def delete_task(user_id, task_id) do
    GenServer.call(via_tuple(user_id), {:delete_task, task_id})
  end

  # ===== CALLBACKS =====

  def init(user_id) do
    categories =
      TasksServices.list_categories(user_id)
      |> Enum.map(fn cat ->
        Map.put(cat, :tasks, TasksServices.list_tasks_by_category(cat.id))
      end)

    {:ok, %{user_id: user_id, categories: categories}}
  end

  def handle_call(:ping, _from, state), do: {:reply, :pong, state}

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_call({:add_category, attrs}, _from, state) do
    attrs = Map.put(attrs, "user_id", state.user_id)

    case TasksServices.create_category(attrs) do
      {:ok, category} ->
        category = Map.put(category, :tasks, [])
        {:reply, {:ok, category}, %{state | categories: [category | state.categories]}}

      {:error, changeset} ->
        {:reply, {:error, changeset}, state}
    end
  end

  def handle_call({:update_category, id, attrs}, _from, state) do
    id = String.to_integer(id)
    case find_category(state.categories, id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      category ->
        case TasksServices.update_category(category, attrs) do
          {:ok, updated} ->
            updated = Map.put(updated, :tasks, category.tasks)
            updated_categories = replace_in_list(state.categories, id, updated)
            {:reply, {:ok, updated}, %{state | categories: updated_categories}}

          {:error, changeset} ->
            {:reply, {:error, changeset}, state}
        end
    end
  end

  def handle_call({:delete_category, id}, _from, state) do
    id = String.to_integer(id)
    case find_category(state.categories, id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      category ->
        case TasksServices.delete_category(category) do
          {:ok, _} ->
            new_cats = Enum.reject(state.categories, &(&1.id == id))
            {:reply, :ok, %{state | categories: new_cats}}

          {:error, _} = err ->
            {:reply, err, state}
        end
    end
  end

  def handle_call({:add_task, attrs}, _from, state) do
    case TasksServices.create_task(attrs) do
      {:ok, task} ->
        updated_categories =
          Enum.map(state.categories, fn cat ->
            if cat.id == task.category_id do
              %{cat | tasks: [task | cat.tasks]}
            else
              cat
            end
          end)

        {:reply, {:ok, task}, %{state | categories: updated_categories}}

      {:error, changeset} ->
        {:reply, {:error, changeset}, state}
    end
  end

  def handle_call({:update_task, id, attrs}, _from, state) do
    id = String.to_integer(id)
    IO.inspect(attrs, label: "Updating task with attrs")

    case TasksServices.get_task(id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      task ->
        case TasksServices.update_task(task, attrs) do
          {:ok, updated} ->
            IO.inspect(updated, label: "Updated task")

            new_cats =
              Enum.map(state.categories, fn cat ->
                if cat.id == updated.category_id do
                  %{cat | tasks: replace_in_list(cat.tasks, id, updated)}
                else
                  %{cat | tasks: Enum.reject(cat.tasks, &(&1.id == id))}
                end
              end)

            {:reply, {:ok, updated}, %{state | categories: new_cats}}

          {:error, changeset} ->
            {:reply, {:error, changeset}, state}
        end
    end
  end

  def handle_call({:delete_task, id}, _from, state) do
    id = String.to_integer(id)
    case TasksServices.get_task(id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      task ->
        case TasksServices.delete_task(task) do
          {:ok, _} ->
            new_cats =
              Enum.map(state.categories, fn cat ->
                %{cat | tasks: Enum.reject(cat.tasks, &(&1.id == id))}
              end)

            {:reply, :ok, %{state | categories: new_cats}}

          {:error, _} = err ->
            {:reply, err, state}
        end
    end
  end

  # ===== HELPERS =====

  defp find_category(categories, id),
    do: Enum.find(categories, &(&1.id == id))

  defp replace_in_list(list, id, new_item) do
    IO.inspect(list)
    IO.inspect(id, label: "Replacing item with ID")
    IO.inspect(new_item, label: "New item")
    Enum.map(list, fn
      %{id: ^id} -> new_item
      other -> other
    end)
  end
end
