defmodule AchaLivro.AchadosTest do
  use AchaLivro.DataCase

  alias AchaLivro.Achados

  describe "achados" do
    alias AchaLivro.Achados.Achado

    import AchaLivro.AccountsFixtures, only: [user_scope_fixture: 0]
    import AchaLivro.AchadosFixtures

    @invalid_attrs %{}

    test "list_achados/1 returns all scoped achados" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      achado = achado_fixture(scope)
      other_achado = achado_fixture(other_scope)
      assert Achados.list_achados(scope) == [achado]
      assert Achados.list_achados(other_scope) == [other_achado]
    end

    test "get_achado!/2 returns the achado with given id" do
      scope = user_scope_fixture()
      achado = achado_fixture(scope)
      other_scope = user_scope_fixture()
      assert Achados.get_achado!(scope, achado.id) == achado
      assert_raise Ecto.NoResultsError, fn -> Achados.get_achado!(other_scope, achado.id) end
    end

    test "create_achado/2 with valid data creates a achado" do
      valid_attrs = %{}
      scope = user_scope_fixture()

      assert {:ok, %Achado{} = achado} = Achados.create_achado(scope, valid_attrs)
      assert achado.user_id == scope.user.id
    end

    test "create_achado/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Achados.create_achado(scope, @invalid_attrs)
    end

    test "update_achado/3 with valid data updates the achado" do
      scope = user_scope_fixture()
      achado = achado_fixture(scope)
      update_attrs = %{}

      assert {:ok, %Achado{} = achado} = Achados.update_achado(scope, achado, update_attrs)
    end

    test "update_achado/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      achado = achado_fixture(scope)

      assert_raise MatchError, fn ->
        Achados.update_achado(other_scope, achado, %{})
      end
    end

    test "update_achado/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      achado = achado_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Achados.update_achado(scope, achado, @invalid_attrs)
      assert achado == Achados.get_achado!(scope, achado.id)
    end

    test "delete_achado/2 deletes the achado" do
      scope = user_scope_fixture()
      achado = achado_fixture(scope)
      assert {:ok, %Achado{}} = Achados.delete_achado(scope, achado)
      assert_raise Ecto.NoResultsError, fn -> Achados.get_achado!(scope, achado.id) end
    end

    test "delete_achado/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      achado = achado_fixture(scope)
      assert_raise MatchError, fn -> Achados.delete_achado(other_scope, achado) end
    end

    test "change_achado/2 returns a achado changeset" do
      scope = user_scope_fixture()
      achado = achado_fixture(scope)
      assert %Ecto.Changeset{} = Achados.change_achado(scope, achado)
    end
  end
end
