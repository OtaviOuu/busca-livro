defmodule AchaLivro.Workers.EstanteVirtual do
  use Oban.Worker, queue: :estante_virtual

  alias AchaLivro.EstanteVirtual
  alias AchaLivro.Shopee
  @impl Oban.Worker
  def perform(_job) do
    EstanteVirtual.scrape_new_books()
    # Shopee.scrape_new_books()
    :ok
  end
end
