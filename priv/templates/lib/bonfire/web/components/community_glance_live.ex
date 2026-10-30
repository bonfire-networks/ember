defmodule Bonfire.Web.Components.CommunityGlanceLive do
  @moduledoc "The facts people compare servers on. Shared by the guest Home and About, under `CommunityAdminsLive`."
  use Bonfire.UI.Common.Web, :stateless_component

  @doc "Adds the notes for guests (reading without an account, invite-only signups)."
  prop is_guest?, :boolean, default: true

  @doc "Spacing from what comes before."
  prop class, :css_class, default: "mt-8"
end
