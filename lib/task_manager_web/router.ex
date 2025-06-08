defmodule TaskManagerWeb.Router do
  use TaskManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug TaskManagerWeb.Plugs.AuthPlug
  end

  # Other scopes may use custom stacks.
  scope "/api", TaskManagerWeb do
    pipe_through :api

    post "/register", AuthController, :create
    post "/login", AuthController, :login
  end

  scope "/api/tasks", TaskManagerWeb do
    pipe_through :api_auth

    post "/", TaskController, :create
    get "/", TaskController, :index
    get "/:id", TaskController, :show
    put "/:id", TaskController, :update
    delete "/:id", TaskController, :delete
  end

  scope "/api/categories", TaskManagerWeb do
    pipe_through :api_auth

    get "/", CategoryController, :index
    post "/", CategoryController, :create
    put "/:id", CategoryController, :update
    delete "/:id", CategoryController, :delete
  end
end
