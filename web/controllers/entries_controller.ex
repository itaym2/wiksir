defmodule Wiksir.EntriesController do
  use Wiksir.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", entries: Wiksir.Entries.Cache.get_entries
  end
end
