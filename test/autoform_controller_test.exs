defmodule AutoformControllerTest do
  use TestAutoformWeb.ConnCase
  doctest Autoform

  describe "GET /users/new" do
    test "Correct fields exist", %{conn: conn} do
      assert response =
               conn
               |> get(user_path(conn, :new))
               |> html_response(200)

      assert response =~ "age"
      assert response =~ "address"
      assert response =~ "name"
    end

    test "Correct form action", %{conn: conn} do
      assert response =
               conn
               |> get(user_path(conn, :new))
               |> html_response(200)

      assert response =~ ~s(action="/users")
    end

    test "Correct types", %{conn: conn} do
      assert response =
               conn
               |> get(user_path(conn, :new))
               |> html_response(200)

      assert response =~ ~s(type="number")
    end
  end

  describe "GET /users/1/edit" do
    test "Correct fields exist", %{conn: conn} do
      assert response =
               conn
               |> get(user_path(conn, :edit, 1))
               |> html_response(200)

      assert response =~ "address"
      assert response =~ "name"
    end

    test "Existing data prefilled in form", %{conn: conn} do
      assert response =
               conn
               |> get(user_path(conn, :edit, 1))
               |> html_response(200)

      assert response =~ "Test User"
      assert response =~ "12 Test Road"
    end

    test "Correct form action", %{conn: conn} do
      assert response =
               conn
               |> get(user_path(conn, :edit, 1))
               |> html_response(200)

      assert response =~ ~s(action="/users/1")
    end

    test "Excluded fields do not display", %{conn: conn} do
      assert response =
               conn
               |> get(user_path(conn, :edit, 1))
               |> html_response(200)

      refute response =~ "age"
    end
  end
end
