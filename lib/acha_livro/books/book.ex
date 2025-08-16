defmodule AchaLivro.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :description, :string, default: "Sem descrição"
    field :image_url, :string, default: ""
    field :price, :decimal, default: 0.0
    field :code, :string, default: ""
    field :href, :string, default: ""
    field :clicks, :integer, default: 0
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :description, :image_url, :price, :code, :href, :clicks])
    |> validate_required([:title, :image_url])
  end
end
