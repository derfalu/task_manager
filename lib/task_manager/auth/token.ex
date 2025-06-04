defmodule TaskManager.Auth.Token do
 @moduledoc """
  Модуль для генерации и валидации JWT токенов.
  """

   use Joken.Config

  @secret_key "123456789" # Лучше вынести в ENV

  def generate_token(user) do
    claims = %{
      "sub" => to_string(user.id),
      "email" => user.email
    }

    signer = Joken.Signer.create("HS256", @secret_key)

    generate_and_sign(claims, signer)
  end

  def verify_token(token) do
    signer = Joken.Signer.create("HS256", @secret_key)

    verify_and_validate(token, signer)
  end
end
