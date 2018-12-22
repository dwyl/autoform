defmodule TestAutoformWeb.Router do
  use TestAutoformWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", TestAutoformWeb do
    # Use the default browser stack
    pipe_through(:browser)

    resources("/users", UserController)
    resources("/addresses", AddressController)
    resources("/custom", CustomController)
    resources("/sample_products", SampleProductController)
    get("/custom_no_path", CustomController, :new_no_path)
    get("/custom_new_product", CustomController, :new_product)
    resources("/do_what_you_love", DoWhatYouLoveController)
  end

  # Other scopes may use custom stacks.
  # scope "/api", TestAutoformWeb do
  #   pipe_through :api
  # end
end
