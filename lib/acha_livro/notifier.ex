defmodule AchaLivro.Notifier do
  alias AchaLivro.Accounts.Scope
  alias AchaLivro.Books.Book
  alias AchaLivro.Achados
  alias AchaLivro.Repo
  import Ecto.Query, warn: false

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(AchaLivro.PubSub, "notifications:#{scope.user.id}")
  end

  def broadcast(%Scope{} = scope, message) do
    Phoenix.PubSub.broadcast(AchaLivro.PubSub, "notifications:#{scope.user.id}", message)
  end

  def call({:ok, %Book{} = book}) do
    terms =
      AchaLivro.Terms.Term
      |> preload(:user)
      |> Repo.all()

    for term <- terms do
      user_scope = %Scope{user: term.user}

      if String.contains?(book.title, term.value) do
        {:ok, achado} = Achados.create_achado(user_scope, %{book_id: book.id})
        IO.inspect(achado, label: "Achado created")
        broadcast(user_scope, {:found_book, book})
      end
    end

    {:ok, book}
  end
end
