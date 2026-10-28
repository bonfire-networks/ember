defmodule Bonfire.Web.Components.CommunityGlanceLive do
  @moduledoc "Admins beside the facts people compare servers on. Shared by the guest Home and About."
  use Bonfire.UI.Common.Web, :stateless_component

  @doc "Admins to list (see `Bonfire.UI.Me.WidgetAdminsLive.list_visible/1`)."
  prop admins, :list, default: []

  @doc "Adds the notes for guests (reading without an account, invite-only signups)."
  prop is_guest?, :boolean, default: true

  @doc "Spacing from what comes before."
  prop class, :css_class, default: "mt-8"
end
