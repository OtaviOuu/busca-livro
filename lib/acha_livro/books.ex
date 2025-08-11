defmodule AchaLivro.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias AchaLivro.Repo

  alias AchaLivro.Books.Book

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
  def list_books() do
    Book
    |> order_by([b], desc: b.inserted_at)
    |> Repo.all()
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

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(scope, %{field: value})
      {:ok, %Book{}}

      iex> create_book(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs) do
    Process.sleep(5_000)

    with {:ok, book = %Book{}} <-
           %Book{}
           |> Book.changeset(attrs)
           |> Repo.insert() do
      broadcast_books({:new_book, book})
      {:ok, book}
    end
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
