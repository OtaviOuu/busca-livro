defmodule AchaLivroWeb.BookLive.Form do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Books
  alias AchaLivro.Books.Book

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage book records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="book-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:image_url]} type="text" label="Image url" />
        <.input field={@form[:price]} type="number" label="Price" step="any" />
        <.input field={@form[:code]} type="text" label="Code" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Book</.button>
          <.button navigate={return_path(@current_scope, @return_to, @book)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    book = Books.get_book!(id)

    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, book)
    |> assign(:form, to_form(Books.change_book(book)))
  end

  defp apply_action(socket, :new, _params) do
    book = %Book{}

    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, book)
    |> assign(:form, to_form(Books.change_book(book)))
  end

  @impl true
  def handle_event("validate", %{"book" => book_params}, socket) do
    changeset = Books.change_book(socket.assigns.book, book_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    save_book(socket, socket.assigns.live_action, book_params)
  end

  defp save_book(socket, :edit, book_params) do
    case Books.update_book(socket.assigns.book, book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> push_navigate(to: "~p/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_book(socket, :new, book_params) do
    case Books.create_book(book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book created successfully")
         |> push_navigate(to: "~p/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _book), do: ~p"/books"
  defp return_path(_scope, "show", book), do: ~p"/books/#{book}"
end
