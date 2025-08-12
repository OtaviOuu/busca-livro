defmodule AchaLivro.AchadosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AchaLivro.Achados` context.
  """

  @doc """
  Generate a achado.
  """
  def achado_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{

      })

    {:ok, achado} = AchaLivro.Achados.create_achado(scope, attrs)
    achado
  end
end
