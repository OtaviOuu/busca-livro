defmodule AchaLivroWeb.PageController do
  use AchaLivroWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
