defmodule Bonfire.Web.Components.HomeHeroLive do
  @moduledoc """
  The guest Home's introduction, profile style (shown below the banner in the board's hero card): the instance icon overlapping the banner, the instance name as the page's `h1`, tagline and description, the join/log in actions, who runs the place, and the community's links as full-width buttons. One surface with no internal dividers, so it reads as a landing page rather than a list of sections. About keeps the tagline-first `AboutIntroLive`.
  """
  use Bonfire.UI.Common.Web, :stateless_component

  alias Bonfire.UI.Common.GuestBoardLive

  @doc "The admins to credit (see `Bonfire.UI.Me.WidgetAdminsLive.list_visible/1`, which applies the hide-from-guests setting)."
  prop admins, :list, default: []

  def icon, do: Config.get([:ui, :theme, :instance_icon], nil)

  def invite_contact?,
    do: Config.get([:ui, :theme, :instance_welcome, :invite_contact_email], nil) not in [nil, ""]

  @doc """
  The host a community link points to, shown as its tooltip instead of guessing what the link is about.

      iex> Bonfire.Web.Components.HomeHeroLive.link_host("https://example.org/help")
      "example.org"

      iex> Bonfire.Web.Components.HomeHeroLive.link_host("/help")
      "/help"
  """
  def link_host(url) do
    case URI.parse(url) do
      %{host: host} when is_binary(host) -> host
      _ -> url
    end
  end

  @doc """
  Splits the admins into those named in the "Run by" line and the rest, which collapse into "and N others": everyone is named up to three, otherwise the first two are.

      iex> Bonfire.Web.Components.HomeHeroLive.split_admins([:a, :b, :c])
      {[:a, :b, :c], []}

      iex> Bonfire.Web.Components.HomeHeroLive.split_admins([:a, :b, :c, :d])
      {[:a, :b], [:c, :d]}
  """
  def split_admins(admins) when length(admins) <= 3, do: {admins, []}
  def split_admins(admins), do: Enum.split(admins, 2)

  @doc """
  What goes before the name at `index` of `count` named admins: nothing for the first, "and" before the last when nobody is collapsed, a comma otherwise.

      iex> Bonfire.Web.Components.HomeHeroLive.admin_separator(0, 2, false)
      ""

      iex> Bonfire.Web.Components.HomeHeroLive.admin_separator(1, 2, false)
      " and "

      iex> Bonfire.Web.Components.HomeHeroLive.admin_separator(1, 2, true)
      ", "
  """
  def admin_separator(0, _count, _more?), do: ""
  def admin_separator(index, count, false) when index == count - 1, do: " " <> l("and") <> " "
  def admin_separator(_index, _count, _more?), do: ", "

  def admin_opts(admin),
    do: [
      id: "about-admin-#{id(admin)}",
      "data-role": "admin-link",
      title: "@" <> e(admin, :character, :username, "")
    ]

  def admin_name(admin),
    do: e(admin, :profile, :name, nil) || e(admin, :character, :username, nil)

  defdelegate instance_name, to: GuestBoardLive
  defdelegate banner_image, to: GuestBoardLive
  defdelegate community_links, to: GuestBoardLive
end
