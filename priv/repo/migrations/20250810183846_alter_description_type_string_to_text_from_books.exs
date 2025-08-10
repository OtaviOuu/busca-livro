defmodule AchaLivro.Repo.Migrations.AlterDescriptionTypeStringToTextFromBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      modify :description, :text
    end
  end
end
