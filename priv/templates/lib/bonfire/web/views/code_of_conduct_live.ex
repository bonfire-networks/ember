defmodule Bonfire.Web.Views.CodeOfConductLive do
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
       page: "conduct",
       selected_tab: :conduct,
       page_title: l("Code of conduct"),
       is_guest?: is_guest?,
       terms: conduct_terms()
     )
     |> assign(Bonfire.UI.Common.GuestBoardLive.layout_assigns(is_guest?))}
  end

  @doc "The instance's code of conduct, or a pointer to the Bonfire project's one when none is configured."
  def conduct_terms do
    case Config.get([:terms, :conduct]) do
      terms when terms in [nil, ""] ->
        l(
          "The instance operator(s) have not yet added a code of conduct. Please use your best judgment, and consult the [code of conduct of the Bonfire project](https://bonfirenetworks.org/conduct) as a reference."
        )

      terms ->
        terms
    end
  end
end
