defmodule AchaLivroWeb.HomeLive do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Terms.Term
  alias AchaLivro.Terms

  def mount(_params, _session, socket) do
    book = %{
      id: 1,
      title: "Elixir in Action, Second Edition",
      description:
        "A hands-on guide to functional programming and design with Elixir, a dynamic, functional language designed for building scalable and maintainable applications.",
      price: "69.90",
      image_url:
        "https://static.estantevirtual.com.br/book/00/FV7-1031-000/FV7-1031-000_detail1.jpg?ts=1734369956998&ims=fit-in/600x800/filters:fill(fff):quality(100)"
    }

    books_sample = [
      Map.put(book, :id, 1),
      Map.put(book, :id, 2),
      Map.put(book, :id, 3),
      Map.put(book, :id, 4),
      Map.put(book, :id, 5),
      Map.put(book, :id, 6),
      Map.put(book, :id, 7),
      Map.put(book, :id, 8),
      Map.put(book, :id, 9),
      Map.put(book, :id, 10),
      Map.put(book, :id, 11),
      Map.put(book, :id, 12)
    ]

    scope = socket.assigns.current_scope
    term = %Term{user_id: scope.user.id}
    term_changeset = Terms.change_term(scope, term)

    socket =
      socket
      |> stream(
        :books,
        books_sample
      )
      |> stream(:terms, Terms.list_terms(scope))
      |> assign(form: to_form(term_changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <ul id="terms-list" class="flex flex-row flex-wrap gap-2 p-4" phx-update="stream">
        <li :for={{dom_id, term} <- @streams.terms} id={dom_id}>
          <span class="badge badge-primary">{term.value}</span>
        </li>
      </ul>
      <.form for={@form} id="term-form" phx-submit="add_term">
        <.input field={@form[:value]} type="text" placeholder="Enter term" />
        <.button type="submit" class="btn btn-primary" phx-disable-with="Adding...">Add Term</.button>
      </.form>
      <div
        class="flex flex-row justify-center gap-6 flex-wrap p-4"
        phx-update="stream"
        id="books-grid"
      >
        <.books_grid :for={{dom_id, book} <- @streams.books} book={book} id={dom_id} />
      </div>
    </Layouts.app>
    """
  end

  def books_grid(assigns) do
    ~H"""
    <div class="card bg-base-100 w-64 shadow-sm hover:shadow-md transition-shadow" id={@id}>
      <figure class="px-4 pt-4">
        <img src={@book.image_url} alt="Livro" class="rounded-xl w-full h-80 object-cover" />
      </figure>
      <div class="card-body p-4">
        <h2 class="card-title text-lg font-semibold line-clamp-2">{@book.title}</h2>
        <p class="text-sm text-base-content/70 mb-2">{@book.description}</p>
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
        changeset = Terms.change_term(user_scope, %Term{user_id: user_scope.user.id, value: ""})

        socket =
          socket
          |> assign(:form, to_form(changeset))
          |> stream_insert(:terms, term, at: 0)

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
