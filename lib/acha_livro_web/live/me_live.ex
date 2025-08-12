defmodule AchaLivroWeb.MeLive do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Achados
  alias AchaLivroWeb.CustomComponents

  @max_achados 20

  def mount(_params, _session, socket) do
    user_scope = socket.assigns.current_scope

    if connected?(socket) do
      send(self(), :loading_books)
      Achados.subscribe_achados(user_scope)
    end

    socket =
      socket
      |> assign(:loading_books, true)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <%= if @loading_books do %>
        <div class="flex flex-row justify-center gap-6 flex-wrap p-4">
          <CustomComponents.book_card_skeleton :for={_book <- 1..get_max_books()} />
        </div>
      <% else %>
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
      <% end %>
    </Layouts.app>
    """
  end

  def handle_info({:created, achado}, socket) do
    socket =
      socket
      |> stream_insert(:achados, achado, at: 0, limit: 20)

    {:noreply, socket}
  end

  def handle_info(:loading_books, socket) do
    user_scope = socket.assigns.current_scope
    achados = Achados.list_achados(user_scope, @max_achados)

    socket =
      socket
      |> update(:loading_books, fn _ -> false end)
      |> stream(:achados, achados, limit: @max_achados)

    {:noreply, socket}
  end

  def get_max_books do
    @max_achados
  end
end
