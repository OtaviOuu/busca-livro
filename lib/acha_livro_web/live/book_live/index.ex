defmodule AchaLivroWeb.BookLive.Index do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Terms.Term
  alias AchaLivro.Terms
  alias AchaLivro.Books
  alias AchaLivro.Achados
  alias AchaLivroWeb.CustomComponents

  @max_books 50

  def mount(_params, _session, socket) do
    connected? = connected?(socket)
    scope = socket.assigns.current_scope

    if connected? do
      send(self(), :loading_books)

      Books.subscribe_books()
    end

    case scope do
      %{user: user} when not is_nil(user) ->
        if connected? do
          Achados.subscribe_achados(scope)
          send(self(), :load_terms)
        end

        term = %Term{user_id: scope.user.id}
        term_changeset = Terms.change_term(scope, term)

        socket =
          socket
          |> assign(form: to_form(term_changeset))
          |> assign(:loading_books, true)
          |> assign(:loading_terms, true)
          |> assign(:loged, true)

        {:ok, socket}

      _ ->
        socket =
          socket
          |> assign(:loading_books, true)
          |> assign(:loged, false)

        {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <%= if @loading_books do %>
        <div class="flex flex-row justify-center gap-6 flex-wrap p-4">
          <CustomComponents.book_card_skeleton :for={_book <- 1..get_max_books()} />
        </div>
      <% else %>
        <CustomComponents.term_form
          :if={@loged && not @loading_terms}
          streams={@streams}
          form={@form}
        />
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

  def handle_event("track_click", %{"id" => id, "url" => url}, socket) do
    book = Books.get_book!(id)

    Books.update_book(book, %{clicks: book.clicks + 1})

    socket =
      socket
      |> push_navigate(to: url)

    {:noreply, socket}
  end

  def handle_event("change", params, socket) do
    current_scope = socket.assigns.current_scope

    changeset =
      Terms.change_term(current_scope, %Term{user_id: current_scope.user.id}, params)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_info({:book_updated, new_book_state}, socket) do
    socket =
      socket
      |> stream_insert(:books, new_book_state)

    {:noreply, socket}
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

  def handle_info(:load_terms, socket) do
    terms = Terms.list_terms(socket.assigns.current_scope)

    socket =
      socket
      |> stream(:terms, terms)
      |> assign(:loading_terms, false)

    {:noreply, socket}
  end

  def handle_info(:loading_books, socket) do
    books = Books.list_books(@max_books)
    # terms = Terms.list_terms(socket.assigns.current_scope)

    socket =
      socket
      |> assign(:len_books, Books.how_many_books())
      |> stream(:books, books, limit: @max_books)
      |> assign(:loading_books, false)

    # |> stream(:terms, terms)

    {:noreply, socket}
  end

  def get_max_books do
    @max_books
  end
end
