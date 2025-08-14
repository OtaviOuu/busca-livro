defmodule AchaLivro.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias AchaLivro.Repo
  alias AchaLivro.Books.Book
  alias AchaLivro.Accounts.Scope
  alias AchaLivro.Achados

  def subscribe_books do
    Phoenix.PubSub.subscribe(AchaLivro.PubSub, "books")
  end

  def broadcast_books(message) do
    Phoenix.PubSub.broadcast(AchaLivro.PubSub, "books", message)
  end

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books(scope)
      [%Book{}, ...]

  """
  def list_books do
    Book
    |> order_by([b], desc: b.id)
    |> Repo.all()
  end

  def list_books(max_books) when is_integer(max_books) and max_books > 0 do
    Book
    |> order_by([b], desc: b.id)
    |> limit(^max_books)
    |> Repo.all()
  end

  def how_many_books do
    Repo.aggregate(Book, :count, :id)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(scope, 123)
      %Book{}

      iex> get_book!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id) do
    Repo.get_by!(Book, id: id)
  end

  def distribute_books_to_users({:ok, %Book{} = book}) do
    terms =
      AchaLivro.Terms.Term
      |> preload(:user)
      |> Repo.all()

    for term <- terms do
      user_scope = %Scope{user: term.user}

      if String.contains?(book.title, term.value) do
        {:ok, _achado} = Achados.create_achado(user_scope, %{book_id: book.id})
        # AchaLivro.Achados.broadcast(user_scope, {:found_book, achado})
      end
    end

    {:ok, book}
  end

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(scope, %{field: value})
      {:ok, %Book{}}

      iex> create_book(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs) do
    with {:ok, book = %Book{}} <-
           %Book{}
           |> Book.changeset(attrs)
           |> Repo.insert()
           |> distribute_books_to_users() do
      broadcast_books({:new_book, book})

      {:ok, book}
    end
  end

  def is_book_in_db?(attrs) do
    Book
    |> where([b], b.code == ^attrs.code)
    |> Repo.exists?()
    |> Kernel.not()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(scope, book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(scope, book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    with {:ok, book = %Book{}} <-
           book
           |> Book.changeset(attrs)
           |> Repo.update() do
      {:ok, book}
    end
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(scope, book)
      {:ok, %Book{}}

      iex> delete_book(scope, book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    with {:ok, book = %Book{}} <-
           Repo.delete(book) do
      {:ok, book}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(scope, book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end
end
