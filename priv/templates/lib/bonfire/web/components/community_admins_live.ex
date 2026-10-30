defmodule Bonfire.Web.Components.CommunityAdminsLive do
  @moduledoc "The instance admins as a grid of profile cards, above `CommunityGlanceLive` on the guest Home and About. Renders nothing without admins."
  use Bonfire.UI.Common.Web, :stateless_component

  @doc "The admins to list (see `Bonfire.UI.Me.WidgetAdminsLive.list_visible/1`, which applies the hide-from-guests setting)."
  prop admins, :list, default: []

  @doc "Spacing from what comes before."
  prop class, :css_class, default: "mt-8"
end
