defmodule AchaLivro.TermsTest do
  use AchaLivro.DataCase

  alias AchaLivro.Terms

  describe "terms" do
    alias AchaLivro.Terms.Term

    import AchaLivro.AccountsFixtures, only: [user_scope_fixture: 0]
    import AchaLivro.TermsFixtures

    @invalid_attrs %{value: nil}

    test "list_terms/1 returns all scoped terms" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      term = term_fixture(scope)
      other_term = term_fixture(other_scope)
      assert Terms.list_terms(scope) == [term]
      assert Terms.list_terms(other_scope) == [other_term]
    end

    test "get_term!/2 returns the term with given id" do
      scope = user_scope_fixture()
      term = term_fixture(scope)
      other_scope = user_scope_fixture()
      assert Terms.get_term!(scope, term.id) == term
      assert_raise Ecto.NoResultsError, fn -> Terms.get_term!(other_scope, term.id) end
    end

    test "create_term/2 with valid data creates a term" do
      valid_attrs = %{value: "some value"}
      scope = user_scope_fixture()

      assert {:ok, %Term{} = term} = Terms.create_term(scope, valid_attrs)
      assert term.value == "some value"
      assert term.user_id == scope.user.id
    end

    test "create_term/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Terms.create_term(scope, @invalid_attrs)
    end

    test "update_term/3 with valid data updates the term" do
      scope = user_scope_fixture()
      term = term_fixture(scope)
      update_attrs = %{value: "some updated value"}

      assert {:ok, %Term{} = term} = Terms.update_term(scope, term, update_attrs)
      assert term.value == "some updated value"
    end

    test "update_term/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      term = term_fixture(scope)

      assert_raise MatchError, fn ->
        Terms.update_term(other_scope, term, %{})
      end
    end

    test "update_term/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      term = term_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Terms.update_term(scope, term, @invalid_attrs)
      assert term == Terms.get_term!(scope, term.id)
    end

    test "delete_term/2 deletes the term" do
      scope = user_scope_fixture()
      term = term_fixture(scope)
      assert {:ok, %Term{}} = Terms.delete_term(scope, term)
      assert_raise Ecto.NoResultsError, fn -> Terms.get_term!(scope, term.id) end
    end

    test "delete_term/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      term = term_fixture(scope)
      assert_raise MatchError, fn -> Terms.delete_term(other_scope, term) end
    end

    test "change_term/2 returns a term changeset" do
      scope = user_scope_fixture()
      term = term_fixture(scope)
      assert %Ecto.Changeset{} = Terms.change_term(scope, term)
    end
  end
end
