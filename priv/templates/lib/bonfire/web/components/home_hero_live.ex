defmodule Bonfire.Web.Components.HomeHeroLive do
  @moduledoc """
  The guest Home's actions, shown under the shared introduction (`AboutIntroLive`): join or log in (or request an invite on invite-only instances), then the community's links (`CommunityLinksLive`). Who runs the place sits in `CommunityAdminsLive`.
  """
  use Bonfire.UI.Common.Web, :stateless_component

  def invite_contact?,
    do: Config.get([:ui, :theme, :instance_welcome, :invite_contact_email], nil) not in [nil, ""]

end
