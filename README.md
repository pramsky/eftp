# Eftp

A Simple FTP Client based on :inets

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `eftp` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:eftp, github: "audian/eftp"}]
end
```

To authenticate and download the file `example.csv`

```elixir
Eftp.connect("ftp.example.net", "21")
|> Eftp.authenticate("foo", "bar")
|> Eftp.fetch("example.csv", "/tmp")
```

To authenticate and download a list of files `example.csv`, `users.csv`

```elixir
Eftp.connect("ftp.example.net", "21")
|> Eftp.authenticate("foo", "bar")
|> Eftp.fetch(["example.csv", "users.csv"], "/tmp")
```
