defmodule AchaLivroWeb.HomeLive do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Terms.Term
  alias AchaLivro.Terms
  alias AchaLivro.Books
  alias AchaLivro.Achados
  alias AchaLivroWeb.CustomComponents

  @max_books 20

  def mount(_params, _session, socket) do
    if connected?(socket) do
      send(self(), :load_books)

      Books.subscribe_books()
      Achados.subscribe_achados(socket.assigns.current_scope)
    end

    scope = socket.assigns.current_scope
    term = %Term{user_id: scope.user.id}
    term_changeset = Terms.change_term(scope, term)

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
        <div class="flex flex-row justify-center gap-6 flex-wrap p-4">
          <.book_grid_skeleton :for={_book <- 1..get_max_books()} />
        </div>
      <% else %>
        <ul id="terms-list" class="flex flex-row flex-wrap gap-2 p-4" phx-update="stream">
          <li :for={{dom_id, term} <- @streams.terms} id={dom_id}>
            <span class="badge badge-primary">{term.value}</span>
          </li>
        </ul>

        {@len_books} books found.
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
          <CustomComponents.book_card :for={{dom_id, book} <- @streams.books} book={book} id={dom_id} />
        </div>
      <% end %>
    </Layouts.app>
    """
  end

  def book_grid_skeleton(assigns) do
    ~H"""
    <div class="card bg-base-100 w-64 shadow-sm hover:shadow-md transition">
      <div class="px-4 pt-4">
        <div class="skeleton h-80 w-full rounded-xl"></div>
      </div>
      <div class="card-body p-4">
        <h2 class="card-title text-lg font-semibold line-clamp-2">
          <div class="skeleton h-6 w-full"></div>
        </h2>
        <p class="text-sm text-base-content/70 mb-2">
          <div class="skeleton h-4 w-24"></div>
        </p>
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
      # |> put_flash(:info, "New book added: #{book.title}")
      |> assign(len_books: socket.assigns.len_books + 1)
      |> stream_insert(:books, book, at: 0, limit: @max_books)

    {:noreply, socket}
  end

  def handle_info({:created, achado}, socket) do
    socket =
      socket
      |> put_flash(:info, "New book found: #{achado.book.title}")

    {:noreply, socket}
  end

  def handle_info(:load_books, socket) do
    books = Books.list_books(@max_books)
    terms = Terms.list_terms(socket.assigns.current_scope)

    socket =
      socket
      |> assign(:load_books, false)
      |> assign(:len_books, Books.how_many_books())
      |> stream(:books, books, limit: @max_books)
      |> stream(:terms, terms)

    {:noreply, socket}
  end

  def get_max_books do
    @max_books
  end
end
