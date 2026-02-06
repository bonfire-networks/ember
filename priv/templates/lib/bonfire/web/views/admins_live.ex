defmodule Bonfire.Web.Views.AdminsLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    is_guest? = is_nil(current_user_id(socket))

    {:ok,
     socket
     |> assign(
       page: "admins",
       selected_tab: :admins,
       page_title: l("admins"),
      #  is_guest?: is_guest?,
      #  without_sidebar: is_guest?,
      #  without_secondary_widgets: is_guest?,
      #  no_header: is_guest?,
       
     )}
  end
end
