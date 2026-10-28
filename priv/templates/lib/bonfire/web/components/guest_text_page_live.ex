defmodule Bonfire.Web.Components.GuestTextPageLive do
  @moduledoc "A markdown text page on the guest board (Code of conduct, Privacy policy, Impressum)."
  use Bonfire.UI.Common.Web, :stateless_component

  prop title, :string, required: true

  @doc "The page's markdown (or a URL to remote markdown, see `templated_or_remote_markdown/2`)."
  prop text, :string, default: nil

  @doc "DOM id of the text body."
  prop body_id, :string, default: nil

  @doc "Anything shown after the text, eg. Impressum's links."
  slot default

  @doc "The instance's text for a terms page (`:conduct`, `:privacy`, `:impressum`), or `fallback` when none is configured (an empty string counts as none)."
  def terms(key, fallback) do
    case Config.get([:terms, key]) do
      terms when terms in [nil, ""] -> fallback
      terms -> terms
    end
  end
end
