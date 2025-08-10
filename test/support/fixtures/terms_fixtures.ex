defmodule AchaLivro.TermsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AchaLivro.Terms` context.
  """

  @doc """
  Generate a term.
  """
  def term_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        value: "some value"
      })

    {:ok, term} = AchaLivro.Terms.create_term(scope, attrs)
    term
  end
end
