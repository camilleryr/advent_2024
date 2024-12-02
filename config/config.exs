import Config

if File.exists?(Path.expand("config/secrets.exs")) do
  import_config "secrets.exs"
end
