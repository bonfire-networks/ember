defmodule Bonfire.Web.Views.ImpressumLive do
  @moduledoc """
  The instance's impressum / legal notice page: a text page in the guest board for guests (reached from its footer), a plain text widget for members.
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    is_guest? = is_nil(current_user_id(socket))

    links =
      Config.get([:ui, :theme, :instance_welcome, :links], [])
      |> Bonfire.UI.Common.WidgetCommunityLinksLive.normalize_links()

    {:ok,
     socket
     |> assign(
       page: "impressum",
       selected_tab: :impressum,
       page_title: l("Impressum"),
       is_guest?: is_guest?,
       terms:
         Bonfire.Web.Components.GuestTextPageLive.terms(
           :impressum,
           l("The instance operator(s) have not yet added an impressum.")
         ),
       links: links
     )
     |> assign(Bonfire.UI.Common.GuestBoardLive.layout_assigns(is_guest?))}
  end
end
