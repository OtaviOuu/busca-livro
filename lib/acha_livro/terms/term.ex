defmodule AchaLivro.Terms.Term do
  use Ecto.Schema
  import Ecto.Changeset
  alias AchaLivro.Repo
  alias AchaLivro.Accounts.User

  @terms_limit 3

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
    |> validate_user_tag_limit(user_scope.user)
  end

  defp validate_user_tag_limit(changeset, user) do
    count = Repo.aggregate(Ecto.assoc(user, :terms), :count, :id)

    if count >= @terms_limit do
      add_error(changeset, :value, "já possui o máximo de 3 tags")
    else
      changeset
    end
  end
end
