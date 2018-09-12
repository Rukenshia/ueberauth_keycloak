defmodule UeberauthGitlabTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest UeberauthGitlab

  @tag :skip
  test "handle_request!" do
    use_cassette "handle_request!" do
      conn = %Plug.Conn{
        params: %{
          client_id: "12345",
          client_secret: "98765",
          redirect_uri: "http://localhost:4000/auth/gitlab/callback",
        }
      }
      result = Ueberauth.Strategy.Gitlab.handle_request!(conn)
      assert result == nil
    end
  end

  describe "handle_callback!" do
    test "with no code"  do
      conn = %Plug.Conn{}
      result = Ueberauth.Strategy.Gitlab.handle_callback!(conn)
      failure = result.assigns.ueberauth_failure
      assert length(failure.errors) == 1
      [no_code_error] = failure.errors

      assert no_code_error.message_key == "missing_code"
      assert no_code_error.message == "No code received"
    end
  end

  describe "handle_cleanup!" do
    test "clears gitlab_user from conn" do
      conn = %Plug.Conn{}
       |> Plug.Conn.put_private(:gitlab_user, %{username: "mtchavez"})

      result = Ueberauth.Strategy.Gitlab.handle_cleanup!(conn)
      assert result.private.gitlab_user == nil
    end
  end

  describe "uid" do
    test "uid_field not found" do
      conn = %Plug.Conn{}
       |> Plug.Conn.put_private(:gitlab_user, %{uid: "not-found-uid"})

      assert Ueberauth.Strategy.Gitlab.uid(conn) == nil
    end

    test "uid_field returned" do
      uid = "abcd1234abcd1234"
      conn = %Plug.Conn{}
       |> Plug.Conn.put_private(:gitlab_user, %{"id" => uid})

      assert Ueberauth.Strategy.Gitlab.uid(conn) == uid
    end
  end

  describe "credentials" do
    test "are returned" do
      conn = %Plug.Conn{}
       |> Plug.Conn.put_private(:gitlab_token, %{access_token: "access-token", refresh_token: "refresh-token", expires: false, expires_at: Time.utc_now(), token_type: "access_code", other_params: %{}})
       creds = Ueberauth.Strategy.Gitlab.credentials(conn)
       assert creds.token == "access-token"
       assert creds.refresh_token == "refresh-token"
       assert creds.expires == true
       assert creds.scopes == [""]
    end
  end

  describe "info" do
    test "is returned" do
      conn = %Plug.Conn{}
       |> Plug.Conn.put_private(:gitlab_user, %{
         "name" => "mtchavez",
         "username" => "mtchavez",
         "email" => "m@t.chavez",
         "location" => "",
         "avatar_url" => "http://the.image.url",
         "web_url" => "https://gitlab.com/mtchavez",
         "website_url" => "",
       })

      info = Ueberauth.Strategy.Gitlab.info(conn)
      assert info.name == "mtchavez"
      assert info.nickname == "mtchavez"
      assert info.email == "m@t.chavez"
      assert info.location == ""
      assert info.image == "http://the.image.url"
      assert info.urls.web_url == "https://gitlab.com/mtchavez"
      assert info.urls.website_url == ""
    end
  end
end
