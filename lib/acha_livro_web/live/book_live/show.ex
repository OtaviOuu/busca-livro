defmodule AchaLivroWeb.BookLive.Show do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Books
  alias AchaLivro.Achados
  alias AchaLivro.Achados.Achado

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    scope = socket.assigns.current_scope

    book = Books.get_book!(id)
    socket = assign(socket, :book, book)

    case scope do
      %{user: user} when not is_nil(user) ->
        if connected?(socket) do
          Achados.subscribe_achados(scope)
        end

        is_book_from_current_user? = Achados.book_is_from_the_user?(scope, id)

        socket =
          socket
          |> assign(:is_book_from_current_user?, is_book_from_current_user?)

        {:noreply, socket}

      _ ->
        socket = assign(socket, :is_book_from_current_user?, false)
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex justify-center p-6 md:p-10">
        <div class="card lg:card-side bg-base-100 shadow-xl hover:shadow-2xl transition max-w-7xl rounded-2xl overflow-hidden">
          <figure class="bg-base-200 flex items-center justify-center p-4 md:p-8 lg:w-1/2">
            <img
              src={@book.image_url}
              alt={@book.title}
              class="w-full h-auto max-w-md mx-auto rounded-lg shadow-lg object-cover"
            />
          </figure>

          <div class="card-body p-5 md:p-8 lg:w-1/2 flex flex-col justify-between">
            <div class="flex flex-col gap-4">
              <h1 class="text-2xl md:text-3xl lg:text-4xl font-bold leading-snug">
                {@book.title}
              </h1>

              <p class="text-2xl font-extrabold text-primary bg-primary/10 px-4 py-2 rounded-lg w-fit shadow-sm">
                R$ {@book.price}
              </p>

              <div class="divider"></div>

              <div class="flex flex-col gap-2">
                <h2 class="text-lg md:text-xl font-bold">Descrição</h2>
                <p class="text-sm md:text-base text-base-content leading-relaxed">
                  {@book.description}
                </p>
              </div>
            </div>

            <div class="flex flex-col gap-3 mt-6">
              <a href={@book.href} target="_blank" class="flex justify-center">
                <button class="btn btn-primary btn-wide">
                  <.icon name="hero-book-open" class="h-5 w-5 mr-2" /> Abrir na Estante Virtual
                </button>
              </a>
              <.link :if={@is_book_from_current_user?} phx-click="delete" class="flex justify-center">
                <button class="btn btn-error btn-wide">
                  <.icon name="hero-trash" class="h-5 w-5 mr-2" /> Deletar livro
                </button>
              </.link>
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
      |> push_navigate(to: ~p"/users/achados")

    {:noreply, socket}
  end
end
