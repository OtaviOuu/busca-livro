defmodule AchaLivro.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :description, :string
    field :image_url, :string
    field :price, :decimal
    field :code, :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :description, :image_url, :price, :code])
    |> validate_required([:title, :description, :image_url, :price, :code])
  end
end
