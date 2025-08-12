defmodule AchaLivroWeb.MeLive do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Achados
  alias AchaLivroWeb.CustomComponents
  alias AchaLivro.Achados

  def mount(_params, _session, socket) do
    user_scope = socket.assigns.current_scope

    if connected?(socket) do
      Achados.subscribe_achados(user_scope)
    end

    achados = Achados.list_achados(user_scope)
    {:ok, socket |> stream(:achados, achados, limit: 20)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div
        class="flex flex-row justify-center gap-6 flex-wrap p-4"
        phx-update="stream"
        id="books-grid"
      >
        <CustomComponents.book_card
          :for={{dom_id, achado} <- @streams.achados}
          book={achado.book}
          id={dom_id}
        />
      </div>
    </Layouts.app>
    """
  end

  def handle_info({:created, achado}, socket) do
    socket =
      socket
      |> stream_insert(:achados, achado, at: 0, limit: 20)

    {:noreply, socket}
  end
end
