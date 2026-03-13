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
      flood("redir to user dashboard")
    case Settings.get([:ui, :homepage_redirect_to], nil, current_user) do
      url when is_binary(url) ->
        {:halt, redirect_to(socket, url, fallback: "/dashboard", replace: false)}
      _ ->
        {:halt, redirect_to(socket, "/dashboard", replace: false)}
    end
  else
    flood("only reached for guests, continues to regular mount to show guest homepage")
    {:cont, socket}
  end
  end

  def mount(_params, _session, socket) do
    flood("mounting HomeLive")
    
    links =
      Config.get([:ui, :theme, :instance_welcome, :links], %{
        l("About Bonfire") => "https://bonfirenetworks.org/",
        l("Contribute") => "https://bonfirenetworks.org/contribute/"
      })

    app = String.capitalize(Bonfire.Application.name_and_flavour())

    # instance_name =
    #   Config.get([:ui, :theme, :instance_name]) || l("An instance of %{app}", app: app)

    {:ok,
     socket
     |> assign(
       page: "home",
       page_title: l("Home"),
       is_guest?: true,
      #  without_sidebar: true,
      #  without_secondary_widgets: true,
      #  no_header: true,
       selected_tab: :home,
       page_title: app,
       links: links,
       #  changelog: @changelog,
       error: nil,
       loading: true,
       feed: nil,
       feed_id: nil,
       feed_ids: nil,
       feed_component_id: nil,
       page_info: nil
       #  
     )}
  end

  # def handle_params(%{"tab" => _tab} = params, url, socket) do
  #   Bonfire.UI.Social.FeedsLive.handle_params(params, url, socket)
  # end

  @decorate time()
  def handle_params(params, _url, socket) do
    # debug(params, "param")

    feed_name =
      if module_enabled?(Bonfire.Social.Pins, socket) and
           Bonfire.Common.Settings.get(
             [Bonfire.UI.Social.FeedsLive, :curated],
             false,
             assigns(socket)
           ) do
        :curated
      else
        # e(assigns(socket), :live_action, nil) ||
        Config.get(
          [Bonfire.UI.Social.FeedLive, :default_feed]
        ) ||
        :local
      end

    {
      :noreply,
      socket
      |> assign(
        Bonfire.Social.Feeds.LiveHandler.feed_default_assigns(
          {
            feed_name,
            params
          },
          socket
        )
      )
    }
  end

  # # render_sface_or_native()
end
