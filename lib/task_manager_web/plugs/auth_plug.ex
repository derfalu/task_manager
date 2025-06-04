defmodule TaskManagerWeb.Plugs.AuthPlug do
  import Plug.Conn
  alias TaskManager.Accounts
  alias TaskManagerWeb.Auth.Token

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{"sub" => user_id}} <- Token.verify_token(token),
         {:ok, user} <- Accounts.get_user_by_id(user_id) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "Unauthorized")
        |> halt()
    end
  end
end
