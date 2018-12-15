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

    test "Excluded fields do not display", %{conn: conn} do
      assert response =
               conn
               |> get(address_path(conn, :new))
               |> html_response(200)

      refute response =~ "Line 1"
    end

    test "Reverse order of :line_1 input box and label", %{conn: conn} do
      response = conn |> get(address_path(conn, :index)) |> html_response(200)
      [h, t] = Regex.split(~r{id=\"address_line_1\"}, response)

      assert response =~ "id=\"address_line_1\""
      refute h =~ "for=\"address_line_1\""
      assert t =~ "for=\"address_line_1\""
    end

    test "Submit button text says Create", %{conn: conn} do
      response = conn |> get(address_path(conn, :new)) |> html_response(200)

      assert response =~ "Create"
    end
  end
end
