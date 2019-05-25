defmodule PtolemyWeb.Router do
  use PtolemyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :require_authenticated do
    plug PtolemyWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PtolemyWeb do
    pipe_through :browser

    get "/auth/sign-in", SessionController, :new
    post "/auth/sign-in", SessionController, :create
  end

  scope "/", PtolemyWeb do
    pipe_through [:browser, :require_authenticated]

    get "/", PageController, :index
    resources "/channels", ChannelController
    resources "/links", LinkController, except: [:index]
    resources "/search", SearchController, only: [:index]
    post "/auth/sign-out", SessionController, :delete
  end
end
