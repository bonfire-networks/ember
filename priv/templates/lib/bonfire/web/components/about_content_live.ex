defmodule Bonfire.Web.Components.AboutContentLive do
  @moduledoc "Community information shared by the guest and signed-in About pages."
  use Bonfire.UI.Common.Web, :stateless_component

  prop is_guest?, :boolean, required: true
  prop selected_tab, :any, default: :about
  prop has_rules?, :boolean, default: false
  prop rules_sections, :list, default: []

  prop admins, :list, default: []

  @doc "Render as a sheet on the guest board (guests) rather than a column in the signed-in layout."
  prop sheet, :boolean, default: false
end
