defmodule Autoform.Supervisor do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Run Autoform Test App endpoint when running tests
    children =
      case Code.ensure_compiled(TestAutoform) do
        {:error, _} ->
          []

        {:module, TestAutoform} ->
          [supervisor(TestAutoformWeb.Endpoint, [])]
      end

    opts = [strategy: :one_for_one, name: Autoform.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
