defmodule AchaLivro.Notifier do
  alias AchaLivro.Accounts.Scope

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(AchaLivro.PubSub, "notifications:#{scope.user.id}")
  end

  def broadcast(%Scope{} = scope, message) do
    Phoenix.PubSub.broadcast(AchaLivro.PubSub, "notifications:#{scope.user.id}", message)
  end
end
