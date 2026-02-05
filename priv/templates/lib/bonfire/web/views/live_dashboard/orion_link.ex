defmodule Bonfire.Web.OrionLink do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  @impl true
  def menu_link(_, _) do
    {:ok, "Orion tracing"}
  end
end
