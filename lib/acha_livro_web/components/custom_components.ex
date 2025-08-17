defmodule AchaLivroWeb.CustomComponents do
  use AchaLivroWeb, :html

  def book_card(assigns) do
    ~H"""
    <div
      class="card bg-base-100 w-64 shadow-md hover:shadow-xl transition duration-300 rounded-2xl overflow-hidden border border-base-200"
      id={@id}
      phx-mounted={JS.transition({"ease-out duration-500", "opacity-0", "opacity-100"}, time: 500)}
      phx-remove={JS.transition({"ease-in duration-500", "opacity-100", "opacity-0"}, time: 500)}
    >
      <.link
        class="block"
        phx-click="track_click"
        phx-value-id={@book.id}
        phx-value-url={~p"/books/#{@book.id}"}
      >
        <figure class="aspect-[3/4] bg-base-200">
          <img
            src={@book.image_url}
            alt={@book.title}
            class="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
          />
        </figure>
      </.link>

      <div class="card-body p-4 gap-3">
        <h2 class="card-title text-base font-semibold line-clamp-2 min-h-[2.5rem]">
          {@book.title}
        </h2>

        <h3
          :if={@book.clicks > 0}
          class="text-sm font-medium text-gray-500 dark:text-gray-400 flex items-center gap-1"
        >
          <span class="animate-bounce">🔥</span> {@book.clicks} clique{if @book.clicks > 1,
            do: "s",
            else: ""}
        </h3>

        <div class="flex justify-between items-center mt-auto">
          <span class="badge badge-outline badge-sm flex items-center gap-1">
            <img src="/images/estante-virtual-logo.png" class="h-4" /> Estante
          </span>
          <span class="text-lg font-bold text-primary">
            R$ {@book.price}
          </span>
        </div>
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
