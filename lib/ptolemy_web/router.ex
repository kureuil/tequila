defmodule PtolemyWeb.Router do
  use PtolemyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PtolemyWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PtolemyWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/channels", ChannelController
    resources "/links", LinkController, except: [:index]
    resources "/users", UserController
  end
end
