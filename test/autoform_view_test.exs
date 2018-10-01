defmodule AutoformViewTest do
  use TestAutoformWeb.ConnCase
  doctest Autoform

  describe "GET /addresses/new - call render_autoform from within template" do
    test "Correct fields exist", %{conn: conn} do
      assert response =
               conn
               |> get(address_path(conn, :new))
               |> html_response(200)

      assert response =~ "postcode"
    end

    test "Other html exists", %{conn: conn} do
      assert response =
               conn
               |> get(address_path(conn, :new))
               |> html_response(200)

      assert response =~ "Addresses"
    end
  end
end
