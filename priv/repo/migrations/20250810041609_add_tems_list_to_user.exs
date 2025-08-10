defmodule AchaLivro.Repo.Migrations.AddTemsListToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :terms, {:array, :string}, default: []
    end
  end
end
