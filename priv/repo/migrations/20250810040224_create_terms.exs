defmodule AchaLivro.Repo.Migrations.CreateTerms do
  use Ecto.Migration

  def change do
    create table(:terms) do
      add :value, :string
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:terms, [:user_id])
  end
end
