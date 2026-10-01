defmodule Bonfire.Web.Views.AboutLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, _session, socket) do
    is_guest? = is_nil(current_user_id(socket))
    current_user = current_user(socket)

    show_users =
      Bonfire.Common.Settings.get(
        [Bonfire.Web.Views.AboutLive, :include, :users],
        false
      )

    {users, page_info} =
      with true <- show_users,
           {_title, %{page_info: page_info, edges: edges}} <-
             Bonfire.UI.Me.UsersDirectoryLive.list_users(current_user, params, nil) do
        {edges, page_info}
      else
        _ -> {[], nil}
      end

    {:ok,
     socket
     |> assign(
       page: "about",
       selected_tab: :about,
       no_header: true,
       is_guest?: is_guest?,
       users: users,
       page_info: page_info,
       page_title: l("About "),
       sidebar_widgets: [
         guests: [
           secondary: [
             #  {Bonfire.Tag.Web.WidgetTagsLive, []},
             #  {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ],
         users: [
           secondary: [
             {Bonfire.Tag.Web.WidgetTagsLive, []},
             {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ]
       ]
     )
     # guests get the public board; About always hides the page header
     |> assign(Bonfire.UI.Common.GuestBoardLive.layout_assigns(is_guest?))
     |> assign(no_header: true)
     |> assign_guest_board(is_guest?)}
  end

  @doc "Loads shared About content once so empty rules and administrator sections can be hidden."
  def assign_guest_board(socket, _is_guest?) do
    rules_sections =
      maybe_apply(Bonfire.CommunityRules, :get_instance_rules_sections, [], fallback_return: [])

    assign(socket,
      rules_sections: rules_sections,
      has_rules?:
        maybe_apply(Bonfire.CommunityRules, :any_rules?, [rules_sections], fallback_return: false),
      admins: Bonfire.UI.Me.WidgetAdminsLive.list_visible(assigns(socket))
    )
  end

  def handle_event("load_more", attrs, socket) do
    {_title, %{page_info: page_info, edges: edges}} =
      Bonfire.UI.Me.UsersDirectoryLive.list_users(current_user(socket), attrs, nil)

    {:noreply,
     socket
     |> assign(
       loaded: true,
       users: e(assigns(socket), :users, []) ++ edges,
       page_info: page_info
     )}
  end

  # catch if the :section id is "privacy"
  def handle_params(%{"section" => "privacy"}, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :privacy)}
  end

  def handle_params(%{"section" => "configuration"}, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :configuration)}
  end

  def handle_params(_tab, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :about)}
  end
end
