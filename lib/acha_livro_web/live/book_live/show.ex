defmodule AchaLivroWeb.BookLive.Show do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Books

  def handle_params(%{"id" => id}, _url, socket) do
    book = Books.get_book!(id)

    socket =
      socket
      |> assign(:book, book)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1>{@book.title}</h1>
      <p>{@book.description}</p>
    </Layouts.app>
    """
  end
end
