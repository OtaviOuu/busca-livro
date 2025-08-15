defmodule AchaLivro.Shopee do
  alias AchaLivro.HttpClient
  alias AchaLivro.Books

  @shopee_api_url "http://localhost:8000/"

  def scrape_new_books do
    {_, books} = HttpClient.get(@shopee_api_url)
    IO.inspect(books, label: "Books Shopee")

    books
    |> Map.get("dados")
    |> Enum.map(&get_useful_book_data/1)
    # |> Enum.filter(&Books.is_book_in_db?/1)
    |> Enum.reverse()
    |> Enum.map(&Books.create_book/1)
  end

  defp get_useful_book_data(book_data) do
    IO.inspect(book_data, label: "Book Data Shopee")

    %{
      title: book_data["title"],
      image_url: book_data["image_url"]
    }
  end
end
