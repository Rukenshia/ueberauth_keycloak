defmodule Ueberauth.Strategy.Keycloak.OAuth do
  @moduledoc """
  An implementation of OAuth2 for keycloak.

  To add your `client_id` and `client_secret` include these values in your configuration.

      config :ueberauth, Ueberauth.Strategy.Keycloak.OAuth,
        client_id: System.get_env("KEYCLOAK_CLIENT_ID"),
        client_secret: System.get_env("KEYCLOAK_CLIENT_SECRET")
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "http://localhost:8080",
    authorize_url: "http://localhost:8080/auth/realms/LMS/protocol/openid-connect/auth",
    token_url: "http://localhost:8080/auth/realms/LMS/protocol/openid-connect/token",
    userinfo_url: "http://localhost:8080/auth/realms/LMS/protocol/openid-connect/userinfo",
    introspect_url:
      "http://localhost:8080/auth/realms/LMS/protocol/openid-connect/token/introspect",
    logout_url: "http://localhost:8080/auth/realms/LMS/protocol/openid-connect/logout",
    token_method: :post
  ]

  @doc """
  Construct a client for requests to Keycloak.

  Optionally include any OAuth2 options here to be merged with the defaults.

      Ueberauth.Strategy.Keycloak.OAuth.client(redirect_uri: "http://localhost:4000/auth/keycloak/callback")

  This will be setup automatically for you in `Ueberauth.Strategy.Keycloak`.
  These options are only useful for usage outside the normal callback phase of Ueberauth.
  """
  def client(opts \\ []) do
    client_opts =
      @defaults
      |> Keyword.merge(config())
      |> Keyword.merge(opts)

    OAuth2.Client.new(client_opts)
  end

  @doc """
  Fetches configuration for `Ueberauth.Strategy.Keycloak.OAuth` Strategy from `config.exs`

  Also checks if at least `client_id` and `client_secret` are set, raising an error if not.
  """
  defp config() do
    :ueberauth
    |> Application.fetch_env!(Ueberauth.Strategy.Keycloak.OAuth)
    |> check_config_key_exists(:client_id)
    |> check_config_key_exists(:client_secret)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  @doc """
  Fetches `userinfo_url` for `Ueberauth.Strategy.Keycloak.OAuth` Strategy from `config.exs`.
  It will be used to get user profile information after an successful authentication.
  """
  def userinfo_url() do
    config() |> Keyword.get(:userinfo_url)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client
    |> put_param("access_token", token)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_token!(params \\ [], options \\ []) do
    headers = Keyword.get(options, :headers, [])
    options = Keyword.get(options, :options, [])
    client_options = Keyword.get(options, :client_options, [])
    client = OAuth2.Client.get_token!(client(client_options), params, headers, options)
    client.token
  end

  # Strategy Callbacks
  def authorize_url(client, params) do
    client
    |> put_param("response_type", "code")
    |> put_param("redirect_uri", client().redirect_uri)

    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_id", client().client_id)
    |> put_param("client_secret", client().client_secret)
    |> put_param("grant_type", "authorization_code")
    |> put_param("redirect_uri", client().redirect_uri)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  def introspect_url(),
    do: config() |> Keyword.get(:introspect_url)

  def logout_url(), do: config() |> Keyword.get(:logout_url)

  def request_post(url, params \\ [], headers \\ []) do
    client = client()

    body =
      [
        client_id: client.client_id,
        client_secret: client.client_secret
      ] ++ params

    client
    |> put_header("content-type", "application/x-www-form-urlencoded")
    |> put_header("accept", "application/json")
    |> OAuth2.Client.post(url, body, headers)
  end

  def introspect(access_token), do: request_post(introspect_url(), token: access_token)

  def logout(refresh_token), do: request_post(logout_url(), refresh_token: refresh_token)

  defp check_config_key_exists(config, key) when is_list(config) do
    unless Keyword.has_key?(config, key) do
      raise "#{inspect(key)} missing from config :ueberauth, Ueberauth.Strategy.Keycloak"
    end

    config
  end

  defp check_config_key_exists(_, _) do
    raise "Config :ueberauth, Ueberauth.Strategy.Keycloak is not a keyword list, as expected"
  end
end
