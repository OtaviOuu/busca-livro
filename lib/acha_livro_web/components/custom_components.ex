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
    <section class="max-w-3xl mx-auto p-6 bg-white dark:bg-gray-900 rounded-3xl shadow-lg border border-gray-200 dark:border-gray-700">
      <h2 class="text-2xl font-extrabold mb-6 text-center text-gray-800 dark:text-gray-100">
        Termos de busca
      </h2>

      <ul id="terms-list" class="flex flex-wrap gap-4 mb-6" phx-update="stream">
        <li
          :for={{dom_id, term} <- @streams.terms}
          id={dom_id}
          class="group transition-transform hover:scale-105 flex items-center gap-2"
        >
          <span class="badge badge-lg badge-primary font-medium px-4 py-2 shadow-md">
            {term.value}
          </span>
          <button
            type="button"
            class="btn btn-xs btn-circle btn-error ml-1 opacity-0 group-hover:opacity-100 transition-opacity duration-200"
            phx-click="delete_term"
            phx-value-id={term.id}
            aria-label="Remover termo"
            title="Remover termo"
          >
            ✕
          </button>
        </li>
      </ul>

      <.form for={@form} id="term-form" phx-submit="add_term" phx-change="change" class="flex gap-3">
        <.input
          field={@form[:value]}
          type="text"
          placeholder="Enter new term"
          class="input input-bordered input-lg flex-1 shadow-sm focus:ring-2 focus:ring-primary focus:border-primary transition"
          autocomplete="off"
          phx-debounce="100"
        />
        <.button class="btn btn-primary btn-lg shadow-lg" phx-disable-with="Adding...">
          Add
        </.button>
      </.form>
    </section>
    """
  end

  def banner(assigns) do
    ~H"""
    <div class="hero bg-base-200 rounded-xl shadow-md my-4">
      <div class="hero-content text-center">
        <div class="max-w-md">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end
end
