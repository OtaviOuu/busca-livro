defmodule AchaLivroWeb.HomeLive do
  use AchaLivroWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}></Layouts.app>
    """
  end
end
