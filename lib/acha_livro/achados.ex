defmodule AchaLivro.Achados do
  @moduledoc """
  The Achados context.
  """

  import Ecto.Query, warn: false
  alias AchaLivro.Repo

  alias AchaLivro.Achados.Achado
  alias AchaLivro.Accounts.Scope
  alias AchaLivro.Books.Book

  @doc """
  Subscribes to scoped notifications about any achado changes.

  The broadcasted messages match the pattern:

    * {:created, %Achado{}}
    * {:updated, %Achado{}}
    * {:deleted, %Achado{}}

  """
  def subscribe_achados(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(AchaLivro.PubSub, "user:#{key}:achados")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(AchaLivro.PubSub, "user:#{key}:achados", message)
  end

  @doc """
  Returns the list of achados.

  ## Examples

      iex> list_achados(scope)
      [%Achado{}, ...]

  """
  def list_achados(%Scope{} = scope) do
    Achado
    |> where(user_id: ^scope.user.id)
    |> preload(:book)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def list_achados(%Scope{} = scope, max) do
    Achado
    |> limit(^max)
    |> where(user_id: ^scope.user.id)
    |> preload(:book)
    |> order_by(desc: :book_id)
    |> Repo.all()
  end

  @doc """
  Gets a single achado.

  Raises `Ecto.NoResultsError` if the Achado does not exist.

  ## Examples

      iex> get_achado!(scope, 123)
      %Achado{}

      iex> get_achado!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_achado!(%Scope{} = scope, id) do
    Repo.get_by!(Achado, id: id, user_id: scope.user.id)
  end

  def get_achado_by_book(%Scope{} = scope, %Book{} = book) do
    Repo.get_by!(Achado, book_id: book.id, user_id: scope.user.id)
  end

  @doc """
  Creates a achado.

  ## Examples

      iex> create_achado(scope, %{field: value})
      {:ok, %Achado{}}

      iex> create_achado(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_achado(%Scope{} = scope, attrs) do
    with {:ok, achado = %Achado{}} <-
           %Achado{}
           |> Achado.changeset(attrs, scope)
           |> Repo.insert() do
      achado = Repo.preload(achado, :book)
      broadcast(scope, {:created, achado})
      {:ok, achado}
    end
  end

  @doc """
  Updates a achado.

  ## Examples

      iex> update_achado(scope, achado, %{field: new_value})
      {:ok, %Achado{}}

      iex> update_achado(scope, achado, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_achado(%Scope{} = scope, %Achado{} = achado, attrs) do
    true = achado.user_id == scope.user.id

    with {:ok, achado = %Achado{}} <-
           achado
           |> Achado.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, achado})
      {:ok, achado}
    end
  end

  @doc """
  Deletes a achado.

  ## Examples

      iex> delete_achado(scope, achado)
      {:ok, %Achado{}}

      iex> delete_achado(scope, achado)
      {:error, %Ecto.Changeset{}}

  """
  def delete_achado(%Scope{} = scope, %Achado{} = achado) do
    true = achado.user_id == scope.user.id

    with {:ok, achado = %Achado{}} <-
           Repo.delete(achado) do
      broadcast(scope, {:deleted, achado |> Repo.preload(:book)})
      {:ok, achado}
    end
  end

  def book_is_from_the_user?(%Scope{} = scope, book_id) do
    book = Repo.get_by(Achado, book_id: book_id, user_id: scope.user.id)
    book != nil
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking achado changes.

  ## Examples

      iex> change_achado(scope, achado)
      %Ecto.Changeset{data: %Achado{}}

  """
  def change_achado(%Scope{} = scope, %Achado{} = achado, attrs \\ %{}) do
    true = achado.user_id == scope.user.id

    Achado.changeset(achado, attrs, scope)
  end
end
