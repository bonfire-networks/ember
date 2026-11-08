defmodule Bonfire.Web.Components.InviteRequestLive do
  @moduledoc "How a guest gets in touch with an invite-only instance: a button that writes to the instance's contact address (nothing when it has set none), and beside it the button to message the moderators, for someone on another server who has no account here. `class` shapes both buttons and `wrapper_class` the row they sit in."
  use Bonfire.UI.Common.Web, :stateless_component

  prop id, :string, default: "about-request-invite"
  prop class, :css_class, default: "px-5"
  prop wrapper_class, :css_class, default: "flex flex-wrap items-center gap-3"

  @doc "The address set for invite requests, if any."
  def email, do: Config.get([:ui, :theme, :instance_welcome, :invite_contact_email], nil)

  @doc "Whether the instance has set an address for invite requests."
  def contact?, do: email() not in [nil, ""]

  @doc "The mail link that writes to `email`."
  def href(email), do: "mailto:#{email}?subject=#{URI.encode(l("Invite request"))}"
end
