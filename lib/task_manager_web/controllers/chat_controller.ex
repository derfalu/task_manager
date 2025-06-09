defmodule TaskManagerWeb.ChatController do
  use TaskManagerWeb, :controller

  def chat(conn, %{"message" => message}) do

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    IO.inspect(message, label: "User Message")

    payload = %{
      "model" => "deepseek/deepseek-r1:free",
      "messages" => [
        %{"role" => "system", "content" => "Ты помощник пользователя."},
        %{"role" => "user", "content" => message}
      ]
    }

    request =
      Finch.build(
        :post,
        "https://openrouter.ai/api/v1/chat/completions",
        headers,
        Jason.encode!(payload)
      )

    with {:ok, %Finch.Response{status: 200, body: raw_body}} <- Finch.request(request, TaskManagerFinch),
         {:ok, response} <- Jason.decode(raw_body),
         content when not is_nil(content) <-
           get_in(response, ["choices", Access.at(0), "message", "content"]) do
      IO.inspect(response, label: "Finch JSON Response")
      json(conn, %{response: content})
    else
      {:ok, %Finch.Response{status: code, body: body}} ->
        IO.inspect(body, label: "Ошибка: тело ответа")
        json(conn, %{error: "Ошибка от OpenRouter: #{code}"})

      {:error, reason} ->
        json(conn, %{error: "Сетевая ошибка: #{inspect(reason)}"})

      _ ->
        json(conn, %{error: "Невозможно извлечь ответ от модели"})
    end
  end
end
