defmodule TequilaWeb.Router do
  use TequilaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TequilaWeb.HelmetPlug
  end

  pipeline :require_authenticated do
    plug TequilaWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TequilaWeb do
    pipe_through :browser

    get "/auth/sign-in", SessionController, :new
    post "/auth/sign-in", SessionController, :create
    get "/reset-password", PasswordResetController, :new
    post "/reset-password", PasswordResetController, :send
    get "/reset-password/:token", PasswordResetController, :reset
    post "/reset-password/:token", PasswordResetController, :apply
    get "/redeem/:invite", InviteController, :redeem
    post "/redeem/:invite", InviteController, :register
  end

  scope "/", TequilaWeb do
    pipe_through [:browser, :require_authenticated]

    get "/", PageController, :index
    resources "/channels", ChannelController
    resources "/links", LinkController, except: [:index]
    resources "/search", SearchController, only: [:index]
    resources "/invites", InviteController, only: [:index, :new, :create, :delete]
    post "/auth/sign-out", SessionController, :delete
  end

  if Mix.env() == :dev do
    scope "/mailbox" do
      pipe_through :browser

      forward "/", Plug.Swoosh.MailboxPreview, base_path: "/mailbox"
    end
  end
end
