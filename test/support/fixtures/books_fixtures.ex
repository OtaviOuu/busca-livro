defmodule AchaLivro.BooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AchaLivro.Books` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        image_url: "some image_url",
        price: "120.5",
        title: "some title"
      })

    {:ok, book} = AchaLivro.Books.create_book(scope, attrs)
    book
  end
end
