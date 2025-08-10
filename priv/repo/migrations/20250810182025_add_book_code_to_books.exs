defmodule AchaLivro.Repo.Migrations.AddBookCodeToBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :code, :string
    end
  end
end
