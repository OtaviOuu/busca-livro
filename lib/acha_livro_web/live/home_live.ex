defmodule AchaLivroWeb.HomeLive do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Terms.Term
  alias AchaLivro.Terms

  alias AchaLivro.Books

  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    term = %Term{user_id: scope.user.id}
    term_changeset = Terms.change_term(scope, term)

    socket =
      socket
      |> stream(:books, Books.list_books(), limit: 50)
      |> stream(:terms, Terms.list_terms(scope))
      |> assign(form: to_form(term_changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
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
        socket =
          socket
          |> stream_insert(:terms, term, at: 0)
          |> put_flash(:info, "Term added successfully")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
