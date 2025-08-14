defmodule AchaLivro.Terms.Term do
  use Ecto.Schema
  import Ecto.Changeset

  alias AchaLivro.Accounts.User

  schema "terms" do
    field :value, :string
    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(term, attrs, user_scope) do
    term
    |> cast(attrs, [:value])
    |> validate_required([:value])
    |> validate_length(:value, min: 3, max: 10)
    |> put_change(:user_id, user_scope.user.id)
  end
end
