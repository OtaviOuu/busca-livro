defmodule AchaLivro.Repo do
  use Ecto.Repo,
    otp_app: :acha_livro,
    adapter: Ecto.Adapters.Postgres
end
