defmodule AchaLivro.EstanteVirtual do
  alias AchaLivro.HttpClient
  alias AchaLivro.Books
  @base_url "https://www.estantevirtual.com.br"
  @static_files_base_url "https://static.estantevirtual.com.br"

  # fazer async talvez n sei
  def scrape_new_books do
    {:ok, response} =
      HttpClient.get(@base_url <> "/ciencias-exatas?sort=new-releases&tipo-de-livro=usado")

    books_data =
      response
      |> Floki.parse_document!()
      |> Floki.find(".product-item__link")
      |> Floki.attribute("href")
      |> Enum.map(&(@base_url <> &1))
      |> Enum.map(&scrape_book_data_by_url/1)
      |> Enum.map(&Books.create_book/1)

    {:ok, books_data}
  end

  def scrape_book_data_by_url(url) do
    {:ok, response} = HttpClient.get(url)

    response
    |> parse_book_json_ld()
    |> List.first()
    |> get_useful_book_data()
  end

  defp get_useful_book_data(book_data) do
    code = book_data["sku"]

    %{
      title: book_data["name"],
      price: book_data["offers"]["lowPrice"],
      description: book_data["description"],
      code: code,
      image_url:
        @static_files_base_url <>
          "/book/00/" <>
          code <> "/" <> code <> "_detail1.jpg"
    }
  end

  defp parse_book_json_ld(html) do
    regex = ~r/<script[^>]*type=["']application\/ld\+json["'][^>]*>(.*?)<\/script>/s

    matches = Regex.scan(regex, html)

    for [_, json_str] <- matches do
      json_str
      |> String.trim()
      |> Jason.decode!()
      |> Map.get("@graph")
      |> List.first()
    end
  end
end
