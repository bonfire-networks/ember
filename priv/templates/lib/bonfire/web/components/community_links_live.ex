defmodule Bonfire.Web.Components.CommunityLinksLive do
  @moduledoc "The instance's community links (`[:ui, :theme, :instance_welcome, :links]`). Shared by the guest Home and Impressum."
  use Bonfire.UI.Common.Web, :stateless_component

  @doc "Spacing from what comes before."
  prop class, :css_class, default: "mt-6"

  @doc """
  The link's host, as its tooltip, rather than a guessed description.

      iex> Bonfire.Web.Components.CommunityLinksLive.link_host("https://example.org/help")
      "example.org"

      iex> Bonfire.Web.Components.CommunityLinksLive.link_host("/help")
      "/help"
  """
  def link_host(url) do
    case URI.parse(url) do
      %{host: host} when is_binary(host) -> host
      _ -> url
    end
  end

  defdelegate community_links, to: Bonfire.UI.Common.GuestBoardLive
end
