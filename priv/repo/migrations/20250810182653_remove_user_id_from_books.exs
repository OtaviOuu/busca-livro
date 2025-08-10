defmodule AchaLivro.Repo.Migrations.RemoveUserIdFromBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      remove :user_id
    end
  end
end
