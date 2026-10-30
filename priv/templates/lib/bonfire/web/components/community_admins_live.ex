defmodule Bonfire.Web.Components.CommunityAdminsLive do
  @moduledoc "The instance moderators as a grid of profile cards with a button to message them all, above `CommunityGlanceLive` on the guest Home and About. Renders nothing without moderators."
  use Bonfire.UI.Common.Web, :stateless_component

  @doc "The admins to list (see `Bonfire.UI.Me.WidgetAdminsLive.list_visible/1`, which applies the hide-from-guests setting)."
  prop admins, :list, default: []

  @doc "Classes of the row, such as the negative margins that take its hairline to the sheet's edges."
  prop class, :css_class, default: nil
end
