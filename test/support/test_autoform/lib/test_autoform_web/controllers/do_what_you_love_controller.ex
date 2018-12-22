defmodule TestAutoformWeb.DoWhatYouLoveController do
  use TestAutoformWeb, :controller
  use Autoform

  alias TestAutoform.DoWhatYouLove

  def new(conn, _params) do
    changeset = DoWhatYouLove.changeset(%DoWhatYouLove{}, %{})

    render_autoform(conn, :create, DoWhatYouLove, assigns: [changeset: changeset])
  end

end
