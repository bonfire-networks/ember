defmodule Bonfire.ExtensionTemplate.RuntimeConfig do
  use Bonfire.Common.Localise

  @behaviour Bonfire.Common.ConfigModule
  def config_module, do: true

  @doc """
  Sets runtime configuration for the extension (typically by reading ENV variables).
  """
  def config do
    import Config

    # config :bonfire_extension_template,
    #   modularity: System.get_env("ENABLE_bonfire_extension_template") || :disabled
  end
end
