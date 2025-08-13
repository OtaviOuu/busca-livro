defmodule AchaLivroWeb.BookLive.Show do
  use AchaLivroWeb, :live_view

  alias AchaLivro.Books

  def handle_params(%{"id" => id}, _url, socket) do
    book = Books.get_book!(id)

    socket =
      socket
      |> assign(:book, book)

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
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
