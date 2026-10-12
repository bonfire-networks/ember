defmodule Bonfire.Web.Components.CommunityAdminsLive do
  @moduledoc "The instance admins as a grid of profile links: a card on the guest Home, a section of the signed-in About page. Renders nothing without admins."
  use Bonfire.UI.Common.Web, :stateless_component

  @doc "The admins to list (see `Bonfire.UI.Me.WidgetAdminsLive.list_visible/1`, which applies the hide-from-guests setting)."
  prop admins, :list, default: []

  @doc "Classes of the section: its padding and how it's separated from its neighbours."
  prop class, :css_class, default: "border-b border-divider px-5 py-6 last:border-b-0 sm:px-6"
end
