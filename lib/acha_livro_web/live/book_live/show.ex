defmodule AchaLivroWeb.BookLive.Show do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Books
  alias AchaLivro.Achados
  alias AchaLivro.Achados.Achado

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Achados.subscribe_achados(socket.assigns.current_scope)
    end

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    book = Books.get_book!(id)

    scope = socket.assigns.current_scope

    socket =
      socket
      |> assign(:book, book)
      |> assign(
        :is_book_from_current_user?,
        Achados.book_is_from_the_user?(scope, id)
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex justify-center p-8">
        <div class="card lg:card-side bg-base-100 shadow-xl max-w-7xl">
          <figure class="p-4 md:p-8 lg:w-1/2">
            <img
              src={@book.image_url}
              alt={@book.title}
              class="w-full h-auto max-w-md mx-auto rounded-lg shadow-md object-cover"
            />
          </figure>
          <div class="card-body p-4 md:p-8 lg:w-1/2">
            <div class="flex flex-col gap-4">
              <h1 class="card-title text-3xl md:text-4xl lg:text-5xl">
                {@book.title}
              </h1>
              <p class="text-xl md:text-2xl font-semibold text-primary-focus">R$ {@book.price}</p>
              <div class="divider"></div>
              <div class="flex flex-col gap-2">
                <h2 class="text-lg md:text-xl font-bold">Descrição</h2>
                <p class="text-sm md:text-base text-gray-600 dark:text-gray-400">
                  {@book.description}
                </p>
                <a
                  href={@book.href}
                  target="_blank"
                  class="mt-4 flex justify-center"
                >
                  <button class="btn btn-wide ">
                    <.icon name="hero-book-open" class="h-5 w-5 mr-2" /> abrir na Estante Virtual
                  </button>
                </a>
                <.link
                  :if={@is_book_from_current_user?}
                  phx-click="delete"
                  class="mt-4 flex justify-center"
                >
                  <button class="btn btn-error btn-wide">
                    <.icon name="hero-trash" class="h-5 w-5 mr-2" /> Deletar livro
                  </button>
                </.link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("delete", _, socket) do
    current_scope = socket.assigns.current_scope

    achado_to_delete = Achados.get_achado_by_book(current_scope, socket.assigns.book)

    Achados.delete_achado(current_scope, achado_to_delete)

    {:noreply, socket}
  end

  def handle_info({:deleted, %Achado{} = achado}, socket) do
    socket =
      socket
      |> put_flash(:info, "Livro '#{achado.book.title}' deletado com sucesso.")
      |> push_navigate(to: ~p"/books/me")

    {:noreply, socket}
  end
end
