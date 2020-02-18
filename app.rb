# frozen_string_literal: true

require "sinatra"
require "sinatra/base"
require "sinatra/reloader"
require "securerandom"
require_relative "lib/memo.rb"

class MemoApp < Sinatra::Base
  configure do
    register Sinatra::Reloader
    enable :method_override
  end

  def check_id(id)
    if 0 == Memo.new.count_id(id)
      halt 404, "404 - そのメモはありません"
    end
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  get "/" do
    @ids = Memo.new.ids
    erb :index
  end

  post "/" do
    Memo.new.insert(h(params[:message]))
    redirect "/"
  end

  get "/new" do
    erb :new
  end

  get "/:id" do
    check_id(params[:id])
    @texts = Memo.new.texts(params[:id]).gsub(/\R/, "<br>")
    erb :show
  end

  get "/:id/edit" do
    check_id(params[:id])
    @texts = Memo.new.texts(params[:id])
    erb :edit
  end

  patch "/:id" do
    check_id(params[:id])
    Memo.new.update(params[:id], h(params[:message]))
    redirect "/"
  end

  delete "/:id" do
    check_id(params[:id])
    Memo.new.delete(params[:id])
    redirect "/"
  end
end
