defmodule TaskManager do
  @moduledoc """
  TaskManager keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def calc_sum(a, b) do
    a + b
  end
end
