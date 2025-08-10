defmodule AchaLivro.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AchaLivroWeb.Telemetry,
      AchaLivro.Repo,
      {DNSCluster, query: Application.get_env(:acha_livro, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AchaLivro.PubSub},
      # Start a worker by calling: AchaLivro.Worker.start_link(arg)
      # {AchaLivro.Worker, arg},
      # Start to serve requests, typically the last entry
      AchaLivroWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AchaLivro.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AchaLivroWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
