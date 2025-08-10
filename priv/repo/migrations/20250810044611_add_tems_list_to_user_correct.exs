defmodule AchaLivro.Repo.Migrations.AddTemsListToUserCorrect do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :terms, {:array, :string}, default: []
    end

    create index(:users, [:terms])
  end
end
