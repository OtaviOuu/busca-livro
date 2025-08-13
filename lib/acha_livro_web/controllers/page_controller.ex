defmodule AchaLivroWeb.PageController do
  use AchaLivroWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/books")
  end
end
