FROM elixir:1.15
WORKDIR /app
COPY . .
ENTRYPOINT ["iex", "-S", "mix"]
EXPOSE 4025