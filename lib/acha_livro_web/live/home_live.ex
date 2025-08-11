defmodule AchaLivroWeb.HomeLive do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Terms.Term
  alias AchaLivro.Terms

  alias AchaLivro.Books

  @max_books 3

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Books.subscribe_books()
    end

    scope = socket.assigns.current_scope
    term = %Term{user_id: scope.user.id}
    term_changeset = Terms.change_term(scope, term)

    send(self(), :load_books)

    socket =
      socket
      |> assign(:load_books, true)
      |> assign(form: to_form(term_changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <%= if @load_books do %>
        <div class="flex justify-center items-center h-screen">
          <span class="loading loading-spinner loading-xl"></span>
        </div>
      <% else %>
        <ul id="terms-list" class="flex flex-row flex-wrap gap-2 p-4" phx-update="stream">
          <li :for={{dom_id, term} <- @streams.terms} id={dom_id}>
            <span class="badge badge-primary">{term.value}</span>
          </li>
        </ul>

        {@len_books}

        <.form for={@form} id="term-form" phx-submit="add_term" phx-change="change">
          <.input field={@form[:value]} type="text" placeholder="Enter term" />
          <.button class="btn btn-primary" phx-disable-with="Adding...">
            Add Term
          </.button>
        </.form>
        <div
          class="flex flex-row justify-center gap-6 flex-wrap p-4"
          phx-update="stream"
          id="books-grid"
        >
          <.books_grid :for={{dom_id, book} <- @streams.books} book={book} id={dom_id} />
        </div>
      <% end %>
    </Layouts.app>
    """
  end

  def books_grid(assigns) do
    ~H"""
    <div
      class="card bg-base-100 w-64 shadow-sm hover:shadow-md transition"
      id={@id}
      phx-mounted={JS.transition({"ease-out duration-300", "opacity-0", "opacity-100"}, time: 300)}
      phx-remove={JS.transition({"ease-in duration-300", "opacity-100", "opacity-0"}, time: 300)}
    >
      <a href={@book.href} target="_blank" class="block">
        <figure class="px-4 pt-4">
          <img src={@book.image_url} alt="Livro" class="rounded-xl w-full h-80 object-cover" />
        </figure>
      </a>
      <div class="card-body p-4">
        <h2 class="card-title text-lg font-semibold line-clamp-2">{@book.title}</h2>
        <p class="text-sm text-base-content/70 mb-2">R$ {@book.price}</p>
      </div>
    </div>
    """
  end

  def handle_event("add_term", %{"term" => %{"value" => term_value}}, socket) do
    user_scope = socket.assigns.current_scope
    term = %{user_id: user_scope.user.id, value: term_value}

    case Terms.create_term(user_scope, term) do
      {:ok, term} ->
        changeset =
          Terms.change_term(user_scope, %Term{user_id: user_scope.user.id}, %{value: ""})

        socket =
          socket
          |> stream_insert(:terms, term, at: 0)
          |> assign(form: to_form(changeset))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("change", params, socket) do
    current_scope = socket.assigns.current_scope

    changeset =
      Terms.change_term(current_scope, %Term{user_id: current_scope.user.id}, params)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_info({:new_book, book}, socket) do
    socket =
      socket
      |> put_flash(:info, "New book added: #{book.title}")
      |> assign(len_books: socket.assigns.len_books + 1)
      |> stream_insert(:books, book, at: 0, limit: @max_books)

    {:noreply, socket}
  end

  def handle_info(:load_books, socket) do
    books = Books.list_books()
    terms = Terms.list_terms(socket.assigns.current_scope)

    socket =
      socket
      |> assign(:load_books, false)
      |> assign(:len_books, length(books))
      |> stream(:books, books, limit: @max_books)
      |> stream(:terms, terms)

    {:noreply, socket}
  end
end
