defmodule AchaLivro.Terms do
  @moduledoc """
  The Terms context.
  """

  import Ecto.Query, warn: false
  alias AchaLivro.Repo

  alias AchaLivro.Terms.Term
  alias AchaLivro.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any term changes.

  The broadcasted messages match the pattern:

    * {:created, %Term{}}
    * {:updated, %Term{}}
    * {:deleted, %Term{}}

  """
  def subscribe_terms(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(AchaLivro.PubSub, "user:#{key}:terms")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(AchaLivro.PubSub, "user:#{key}:terms", message)
  end

  @doc """
  Returns the list of terms.

  ## Examples

      iex> list_terms(scope)
      [%Term{}, ...]

  """
  def list_terms(%Scope{} = scope) do
    Repo.all_by(Term, user_id: scope.user.id)
  end

  @doc """
  Gets a single term.

  Raises `Ecto.NoResultsError` if the Term does not exist.

  ## Examples

      iex> get_term!(scope, 123)
      %Term{}

      iex> get_term!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_term!(%Scope{} = scope, id) do
    Repo.get_by!(Term, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a term.

  ## Examples

      iex> create_term(scope, %{field: value})
      {:ok, %Term{}}

      iex> create_term(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_term(%Scope{} = scope, attrs) do
    with {:ok, term = %Term{}} <-
           %Term{}
           |> Term.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, term})
      {:ok, term}
    end
  end

  @doc """
  Updates a term.

  ## Examples

      iex> update_term(scope, term, %{field: new_value})
      {:ok, %Term{}}

      iex> update_term(scope, term, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_term(%Scope{} = scope, %Term{} = term, attrs) do
    true = term.user_id == scope.user.id

    with {:ok, term = %Term{}} <-
           term
           |> Term.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, term})
      {:ok, term}
    end
  end

  @doc """
  Deletes a term.

  ## Examples

      iex> delete_term(scope, term)
      {:ok, %Term{}}

      iex> delete_term(scope, term)
      {:error, %Ecto.Changeset{}}

  """
  def delete_term(%Scope{} = scope, %Term{} = term) do
    true = term.user_id == scope.user.id

    with {:ok, term = %Term{}} <-
           Repo.delete(term) do
      broadcast(scope, {:deleted, term})
      {:ok, term}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking term changes.

  ## Examples

      iex> change_term(scope, term)
      %Ecto.Changeset{data: %Term{}}

  """
  def change_term(%Scope{} = scope, %Term{} = term, attrs \\ %{}) do
    true = term.user_id == scope.user.id

    Term.changeset(term, attrs, scope)
  end
end
