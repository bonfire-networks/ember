import Config

#### General configuration useful for tests, everything else should be in `bonfire_extension_template.exs` or `Bonfire.ExtensionTemplate.RuntimeConfig`

# You probably won't want to touch these. You might override some in
# other config files.

config :bonfire, :repo_module, Bonfire.Common.Repo

config :phoenix, :json_library, Jason

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mime, :types, %{
  "application/activity+json" => ["activity+json"]
}

config :bonfire_extension_template, :otp_app, :bonfire_extension_template
config :bonfire_common, :otp_app, :bonfire_extension_template
config :bonfire_extension_template, :repo_module, Bonfire.Common.Repo
config :bonfire_extension_template, ecto_repos: [Bonfire.Common.Repo]
config :bonfire_common, :localisation_path, "priv/localisation"

config :bonfire_data_identity, Bonfire.Data.Identity.Credential, hasher_module: Argon2

import_config "bonfire_extension_template.exs"
# import_config "#{Mix.env()}.exs"
