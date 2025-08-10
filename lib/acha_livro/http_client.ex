defmodule AchaLivro.HttpClient do
  def get(url, headers \\ []) do
    case Req.get(url, headers: headers) do
      {:ok, response} -> {:ok, response.body}
      {:error, reason} -> {:error, reason}
    end
  end

  def post(url, body, headers \\ []) do
    case Req.post(url, body: body, headers: headers) do
      {:ok, response} -> {:ok, response.body}
      {:error, reason} -> {:error, reason}
    end
  end
end
