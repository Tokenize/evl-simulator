FROM elixir:otp-24-slim
WORKDIR /app
COPY . .
ENTRYPOINT ["iex", "-S", "mix"]
EXPOSE 4025