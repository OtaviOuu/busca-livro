defmodule AchaLivro.Achados.Achado do
  use Ecto.Schema
  import Ecto.Changeset

  alias AchaLivro.Books.Book

  schema "achados" do
    belongs_to :book, Book
    field :user_id, :id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(achado, attrs, user_scope) do
    achado
    |> cast(attrs, [:book_id])
    |> validate_required([:book_id])
    |> put_change(:user_id, user_scope.user.id)
  end
end
