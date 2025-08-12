defmodule AchaLivroWeb.MeLive do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Achados
  alias AchaLivroWeb.CustomComponents

  def mount(_params, _session, socket) do
    user_scope = socket.assigns.current_scope
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
end
