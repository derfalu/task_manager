defmodule TaskManagerWeb.Router do
  use TaskManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", TaskManagerWeb do
    pipe_through :api

    post "/register", AuthController, :create
    post "/login", AuthController, :login
  end

end
