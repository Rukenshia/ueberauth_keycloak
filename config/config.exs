# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :ueberauth_gitlab, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:ueberauth_gitlab, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

if Mix.env == :test do
  config :exvcr, [
    vcr_cassette_library_dir: "fixture/vcr_cassettes",
    custom_cassette_library_dir: "fixture/custom_cassettes",
    filter_sensitive_data: [
      [pattern: "<PASSWORD>.+</PASSWORD>", placeholder: "PASSWORD_PLACEHOLDER"]
    ],
    filter_url_params: [
      [pattern: "client_secret=.*\&?", placeholder: "CLIENT_SECRET"]
    ],
    filter_request_headers: [],
    response_headers_blacklist: []
  ]

  config :ueberauth, Ueberauth,
    providers: [
      gitlab: { Ueberauth.Strategy.Gitlab, [default_scope: "api read_user read_registry", api_version: "v4"] }
    ]
  config :ueberauth, Ueberauth.Strategy.Gitlab.OAuth,
    client_id: System.get_env("GITLAB_CLIENT_ID"),
    client_secret: System.get_env("GITLAB_CLIENT_SECRET")

end
