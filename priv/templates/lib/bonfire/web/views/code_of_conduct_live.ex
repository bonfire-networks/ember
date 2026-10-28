defmodule Bonfire.Web.Views.CodeOfConductLive do
  @moduledoc """
  The instance's code of conduct: a text page in the guest board for guests, a plain text widget for members.
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    is_guest? = is_nil(current_user_id(socket))

    {:ok,
     socket
     |> assign(
       page: "conduct",
       selected_tab: :conduct,
       page_title: l("Code of conduct"),
       is_guest?: is_guest?,
       terms:
         Bonfire.Web.Components.GuestTextPageLive.terms(
           :conduct,
           l(
             "The instance operator(s) have not yet added a code of conduct. Please use your best judgment, and consult the [code of conduct of the Bonfire project](https://bonfirenetworks.org/conduct) as a reference."
           )
         )
     )
     |> assign(Bonfire.UI.Common.GuestBoardLive.layout_assigns(is_guest?))}
  end
end
