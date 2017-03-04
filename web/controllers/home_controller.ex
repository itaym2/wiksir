defmodule Wiksir.HomeController do
  use Wiksir.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
