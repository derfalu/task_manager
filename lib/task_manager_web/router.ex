defmodule TaskManagerWeb.Router do
  use TaskManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug TaskManagerWeb.Plugs.AuthenticateUser
  end

  # Other scopes may use custom stacks.
  scope "/api", TaskManagerWeb do
    pipe_through :api

    post "/register", AuthController, :create
    post "/login", AuthController, :login
  end
end
