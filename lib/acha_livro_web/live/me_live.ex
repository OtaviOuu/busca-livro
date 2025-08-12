defmodule AchaLivroWeb.MeLive do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Achados

  def mount(_params, _session, socket) do
    user_scope = socket.assigns.current_scope
    achados = Achados.list_achados(user_scope)
    {:ok, socket |> assign(:achados, achados)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1>My Profile</h1>
      <div :for={achado <- @achados} class="achado-item">
        <p>{achado.book.title}</p>
      </div>
    </Layouts.app>
    """
  end
end
