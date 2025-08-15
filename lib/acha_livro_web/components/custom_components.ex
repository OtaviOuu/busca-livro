defmodule AchaLivroWeb.CustomComponents do
  use AchaLivroWeb, :html

  def book_card(assigns) do
    ~H"""
    <div
      class="card bg-base-100 w-64 shadow-sm hover:shadow-md transition"
      id={@id}
      phx-mounted={JS.transition({"ease-out duration-600", "opacity-0", "opacity-100"}, time: 600)}
      phx-remove={JS.transition({"ease-in duration-600", "opacity-100", "opacity-0"}, time: 600)}
    >
      <.link navigate={~p"/books/#{@book.id}"} target="_blank" class="block">
        <figure class="px-4 pt-4">
          <img src={@book.image_url} alt="Livro" class="rounded-xl w-full h-80 object-cover" />
        </figure>
      </.link>
      <div class="card-body p-4">
        <h2 class="card-title text-lg font-semibold line-clamp-2">{@book.title}</h2>
        <div class="flex flex-row justify-center gap-4">
          <img src="/images/estante-virtual-logo.png" width="50" />
        </div>
        <p class="text-sm text-base-content/70 mb-2">R$ {@book.price}</p>
      </div>
    </div>
    """
  end

  def book_card_skeleton(assigns) do
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

  attr :form, :any, doc: "The form to be rendered in the term form component"
  attr :streams, :map, doc: "Streams for terms"

  def term_form(assigns) do
    ~H"""
    <section>
      <ul id="terms-list" class="flex flex-row flex-wrap gap-2 p-4" phx-update="stream">
        <li :for={{dom_id, term} <- @streams.terms} id={dom_id}>
          <span class="badge badge-primary">{term.value}</span>
        </li>
      </ul>

      <.form for={@form} id="term-form" phx-submit="add_term" phx-change="change">
        <.input field={@form[:value]} type="text" placeholder="Enter term" />
        <.button class="btn btn-primary" phx-disable-with="Adding...">
          Add Term
        </.button>
      </.form>
    </section>
    """
  end
end
