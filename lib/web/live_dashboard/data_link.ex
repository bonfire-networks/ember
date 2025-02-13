defmodule Bonfire.Web.DataLink do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  @impl true
  def menu_link(_, _) do
    {:ok, "Data"}
  end
end
