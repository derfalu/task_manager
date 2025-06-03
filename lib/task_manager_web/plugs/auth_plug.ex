defmodule TaskManagerWeb.Plugs.AuthPlug do
  import Plug.Conn
  alias TaskManager.Accounts

  def init(default), do: default

  def call(conn, _default) do
    if get_session(conn, :user_id) do
      conn
    else
      conn
      |> halt()
    end
  end
end
