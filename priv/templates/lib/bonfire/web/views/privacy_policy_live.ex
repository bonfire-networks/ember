defmodule Bonfire.Web.Views.PrivacyPolicyLive do
  @moduledoc """
  The instance's privacy policy: a text page in the guest board for guests (reached from its footer), a plain text widget for members.
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    is_guest? = is_nil(current_user_id(socket))

    {:ok,
     socket
     |> assign(
       page: "privacy",
       page_title: l("Privacy policy"),
       is_guest?: is_guest?,
       terms:
         Bonfire.Web.Components.GuestTextPageLive.terms(
           :privacy,
           l(
             "The instance operator(s) have not yet added a privacy policy. You can consult the [privacy policy of the Bonfire project](https://bonfirenetworks.org/privacy) as a reference."
           )
         )
     )
     |> assign(Bonfire.UI.Common.GuestBoardLive.layout_assigns(is_guest?))}
  end
end
