use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :autoform, TestAutoformWeb.Endpoint,
  secret_key_base: "QeeCG58mpWuM3J1UPRVIA47KTVkFyUWS9SrWYHdJzAmtYYPZSqGZ/R1KBIf/80B+",
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
