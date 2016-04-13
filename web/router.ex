defmodule Changelog.Router do
  use Changelog.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Changelog.Plug.Auth, repo: Changelog.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :put_layout, {Changelog.LayoutView, :admin}
    plug Changelog.Plug.RequireAdmin
  end

  scope "/admin", Changelog.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/", PageController, :index
    get "/search", SearchController, :index

    resources "/people", PersonController
    resources "/podcasts", PodcastController do
      resources "/episodes", EpisodeController
    end
    resources "/topics", TopicController
  end

  scope "/", Changelog do
    pipe_through :browser

    resources "/people", PersonController, only: [:show]
    resources "/topics", TopicController, only: [:show]

    get "/", PageController, :index

    get "/in", AuthController, :new, as: :sign_in
    post "/in", AuthController, :new, as: :sign_in
    get "/in/:token", AuthController, :create, as: :create_sign_in
    get "/out", AuthController, :delete, as: :sign_out
    get "/:slug", PodcastController, :show, as: :podcast
    get "/:slug/feed", PodcastController, :feed, as: :podcast_feed
    get "/:podcast/:slug", PodcastController, :episode, as: :episode
  end
end
