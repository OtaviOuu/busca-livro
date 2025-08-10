defmodule AchaLivroWeb.BookLive.Index do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Books

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Books
        <:actions>
          <.button variant="primary" navigate={~p"/books/new"}>
            <.icon name="hero-plus" /> New Book
          </.button>
        </:actions>
      </.header>

      <.table
        id="books"
        rows={@streams.books}
        row_click={fn {_id, book} -> JS.navigate(~p"/books/#{book}") end}
      >
        <:col :let={{_id, book}} label="Title">{book.title}</:col>
        <:col :let={{_id, book}} label="Description">{book.description}</:col>
        <:col :let={{_id, book}} label="Image url">{book.image_url}</:col>
        <:col :let={{_id, book}} label="Price">{book.price}</:col>
        <:col :let={{_id, book}} label="Code">{book.code}</:col>
        <:action :let={{_id, book}}>
          <div class="sr-only">
            <.link navigate={~p"/books/#{book}"}>Show</.link>
          </div>
          <.link navigate={~p"/books/#{book}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, book}}>
          <.link
            phx-click={JS.push("delete", value: %{id: book.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Books")
     |> stream(:books, Books.list_books())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Books.get_book!(id)
    {:ok, _} = Books.delete_book(book)

    {:noreply, stream_delete(socket, :books, book)}
  end

  @impl true
  def handle_info({type, %AchaLivro.Books.Book{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :books, Books.list_books(), reset: true)}
  end
end
