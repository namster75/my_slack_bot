defmodule MySlackBotWeb.PageController do
  use MySlackBotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
