defmodule AchaLivro.Repo.Migrations.RemoveWrongTermFromUser2 do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :terms, :string, array: true, default: []
    end
  end
end
