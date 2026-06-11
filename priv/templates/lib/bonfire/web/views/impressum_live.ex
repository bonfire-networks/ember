defmodule Bonfire.Web.Views.ImpressumLive do
  @moduledoc """
  The instance's impressum / legal notice page
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page: "impressum",
       selected_tab: :impressum,
       page_title: l("Impressum"),
       terms: Config.get([:terms, :impressum])
     )}
  end
end
