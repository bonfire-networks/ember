defmodule Bonfire.Web.Views.HomeLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view
  use_if_enabled(Bonfire.UI.Common.Web.Native, :view)

  # use_if_enabled(Bonfire.UI.Common.Web.Native, [:view, layouts: [swiftui: {Bonfire.UI.Common.LayoutView.SwiftUI, :app_tab}]])

  alias Bonfire.Me.Accounts
  # @changelog File.read!("#{Config.get(:project_path, "../..")}/docs/CHANGELOG.md")

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}
  on_mount {__MODULE__, :pre_mount}

  def on_mount(:pre_mount, _params, _session, socket) do
    if current_user = current_user_or_id(socket) do
      debug("redir to user dashboard")

      case Settings.get([:ui, :homepage_redirect_to], nil, current_user) do
        url when is_binary(url) ->
          {:halt, redirect_to(socket, url, fallback: "/dashboard", replace: false)}

        _ ->
          {:halt, redirect_to(socket, "/dashboard", replace: false)}
      end
    else
      debug("only reached for guests, continues to regular mount to show guest homepage")
      {:cont, socket}
    end
  end

  def mount(_params, _session, socket) do
    debug("mounting HomeLive")

    # links =
    #   Config.get([:ui, :theme, :instance_welcome, :links], [
    #     {"About Bonfire", "https://bonfirenetworks.org/"},
    #     {"Contribute", "https://bonfirenetworks.org/contribute/"}
    #   ])
    #   |> Bonfire.UI.Common.WidgetCommunityLinksLive.normalize_links()

    app = String.capitalize(Bonfire.Application.name_and_flavour())

    # instance_name =
    #   Config.get([:ui, :theme, :instance_name]) || l("An instance of %{app}", app: app)

    {:ok,
     socket
     |> assign(
       page: "home",
       is_guest?: true,
       # the homepage's widgets, as the instance chose them (Widgets › Homepage in instance settings), starting from the flavour's (`config :bonfire, Bonfire.Web.Views.HomeLive, widgets: [main: [...]]`)
       home_widgets: Bonfire.UI.Common.Widgets.for_place({__MODULE__, :main}, nil),
       selected_tab: :home,
       page_title: app,
       sidebar_widgets: [
         guests: [
           secondary: [
             #  {Bonfire.UI.Common.WidgetCommunityLinksLive, [links: links]}
           ]
         ]
       ],
       #  changelog: @changelog,
       error: nil
     )
     |> assign(Bonfire.UI.Common.GuestBoardLive.layout_assigns(true))}
  end

  # def handle_params(%{"tab" => _tab} = params, url, socket) do
  #   Bonfire.UI.Social.FeedsLive.handle_params(params, url, socket)
  # end

  # # render_sface_or_native()
end
