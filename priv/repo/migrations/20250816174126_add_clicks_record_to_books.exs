defmodule AchaLivro.Repo.Migrations.AddClicksRecordToBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :clicks, :integer, default: 0
    end
  end
end
