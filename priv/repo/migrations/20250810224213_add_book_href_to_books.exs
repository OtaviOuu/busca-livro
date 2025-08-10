defmodule AchaLivro.Repo.Migrations.AddBookHrefToBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :href, :string, null: false, default: ""
    end
  end
end
