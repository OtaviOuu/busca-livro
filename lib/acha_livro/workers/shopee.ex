defmodule AchaLivro.Workers.Shopee do
  use Oban.Worker, queue: :shopee

  alias AchaLivro.Shopee
  @impl Oban.Worker
  def perform(_job) do
    Shopee.scrape_new_books()
    :ok
  end
end
