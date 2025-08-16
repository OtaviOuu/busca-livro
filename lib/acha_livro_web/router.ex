defmodule AchaLivroWeb.Router do
  use AchaLivroWeb, :router

  import Oban.Web.Router
  import AchaLivroWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AchaLivroWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AchaLivroWeb do
    pipe_through :browser

    live_session :books,
      on_mount: {AchaLivroWeb.UserAuth, :mount_current_scope} do
      live "/", BookLive.Index, :index
      live "/books", BookLive.Index, :index
      live "/books/:id", BookLive.Show, :show
    end
  end

  scope "/users", AchaLivroWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :default,
      on_mount: [{AchaLivroWeb.UserAuth, :mount_current_scope}] do
      live "/me", MeLive, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AchaLivroWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:acha_livro, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AchaLivroWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    scope "/" do
      pipe_through :browser

      oban_dashboard("/oban")
    end
  end

  ## Authentication routes

  scope "/", AchaLivroWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AchaLivroWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", AchaLivroWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{AchaLivroWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
