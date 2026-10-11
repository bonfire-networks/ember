defmodule Bonfire.Web.Components.AboutIntroLive do
  @moduledoc "The community introduction (tagline, guest note and description) shown at the top of the guest Home and the About page. The tagline is the page's `h1`, with id `about-tagline` for `aria-labelledby`."
  use Bonfire.UI.Common.Web, :stateless_component

  prop is_guest?, :boolean, required: true
end
