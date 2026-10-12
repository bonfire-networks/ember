defmodule Bonfire.Web.Components.AboutContentLive do
  @moduledoc "Shared community information for guest and signed-in About pages."
  use Bonfire.UI.Common.Web, :stateless_component

  prop is_guest?, :boolean, required: true
  prop selected_tab, :any, default: :about
  prop has_rules?, :boolean, default: false
  prop rules_sections, :list, default: []
  prop admins, :list, default: []
end
