defmodule AchaLivro.Repo.Migrations.CreateAchados do
  use Ecto.Migration

  def change do
    create table(:achados) do
      add :book_id, references(:books, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:achados, [:user_id])

    create index(:achados, [:book_id])
  end
end
