defmodule Bonfire.Web.Components.AboutContentLive do
  @moduledoc "Shared community information for guest and signed-in About pages."
  use Bonfire.UI.Common.Web, :stateless_component

  prop is_guest?, :boolean, required: true
  prop selected_tab, :any, default: :about
  prop has_rules?, :boolean, default: false
  prop rules_sections, :list, default: []
  prop admins, :list, default: []

  @doc """
  Describes built-in destinations and identifies custom resources by their host without guessing their purpose.

      iex> Bonfire.Web.Components.AboutContentLive.describe_community_link("https://example.org/help")
      "example.org"

      iex> Bonfire.Web.Components.AboutContentLive.describe_community_link("/help")
      "/help"
  """
  def describe_community_link(url) do
    case String.trim_trailing(url, "/") do
      "https://bonfirenetworks.org" ->
        l("Discover the platform behind this community")

      "https://socialhub.activitypub.rocks/g/bonfire/activity/posts" ->
        l("Ask questions and share ideas")

      "https://matrix.to/#/%23bonfire-networks:matrix.org" ->
        l("Connect with the wider Bonfire community")

      "https://bonfirenetworks.org/contribute" ->
        l("Help build and support Bonfire")

      _ ->
        url
        |> URI.parse()
        |> Map.get(:host)
        |> case do
          nil -> url
          host -> host
        end
    end
  end
end
