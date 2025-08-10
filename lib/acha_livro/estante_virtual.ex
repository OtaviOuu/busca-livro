defmodule AchaLivro.EstanteVirtual do
  alias AchaLivro.HttpClient
  alias AchaLivro.Books
  @base_url "https://www.estantevirtual.com.br"
  @static_files_base_url "https://static.estantevirtual.com.br"

  # fazer async talvez n sei
  def scrape_new_books do
    {:ok, response} =
      HttpClient.get(@base_url <> "/ciencias-exatas?sort=new-releases&tipo-de-livro=usado")

    new_books =
      response
      |> parse_main_page_json()
      |> get_in(["SearchPage", "parentSkus"])
      |> Enum.map(&get_useful_book_data/1)
      |> Enum.map(&Books.create_book/1)

    {:ok, new_books}
  end

  defp get_useful_book_data(book_data) do
    %{
      title: book_data["name"],
      price: book_data["listPrice"],
      description: book_data["description"],
      code: book_data["code"],
      image_url: book_data["image"]
    }
  end

  defp parse_main_page_json(html) do
    regex = ~r/window\.__INITIAL_STATE__\s*=\s*(\{.*\})/s

    case Regex.run(regex, html) do
      [_, json_string] ->
        case Jason.decode(json_string) do
          {:ok, map} ->
            map

          {:error, _error} ->
            nil
        end
    end
  end
end
