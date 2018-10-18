defmodule CustomTest do
  use TestAutoformWeb.ConnCase
  doctest Autoform

  describe "Using custom_render_autoform" do
    test "Page succesfully renders", %{conn: conn} do
      assert response =
               conn
               |> get(custom_path(conn, :new))
               |> html_response(200)

      assert response =~ "Custom Form"
    end

    test "Schema fields are correctly rendered", %{conn: conn} do
      assert response =
               conn
               |> get(custom_path(conn, :new))
               |> html_response(200)

      assert response =~ "Line 1"
      assert response =~ "Postcode"
    end

    test "Exclude Schema fields are not rendered", %{conn: conn} do
      assert response =
               conn
               |> get(custom_path(conn, :new))
               |> html_response(200)

      assert response =~ "Name"
      assert response =~ "Address"
      refute response =~ "Age"
    end

    test "HTML string is rendered", %{conn: conn} do
      assert response =
               conn
               |> get(custom_path(conn, :new))
               |> html_response(200)

      assert response =~ "Between address and user"
    end

    test "Elements are ordered correctly", %{conn: conn} do
      assert response =
               conn
               |> get(custom_path(conn, :new))
               |> html_response(200)

      Enum.reduce(["Custom Form", "Line 1", "Between", "Name"], -1, fn a, b ->
        {index, _} = :binary.match(response, a)
        assert b < index
        index
      end)
    end

    test "Form goes to correct endpoint", %{conn: conn} do
      assert response =
               conn
               |> get(custom_path(conn, :new))
               |> html_response(200)

      assert response =~ "/endpoint"
    end

    test "no path defaults to calling module's name", %{conn: conn} do
      assert response =
               conn
               |> get(custom_path(conn, :new_no_path))
               |> html_response(200)

      assert response =~ "/custom"
    end

    test "labels are replaced with custom options", %{conn: conn} do
      assert response =
               conn
               |> get(custom_path(conn, :new))
               |> html_response(200)

      assert response =~ "Years on Earth"
      refute response =~ "Age"
    end
  end
end
