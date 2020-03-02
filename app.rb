# frozen_string_literal: true

require "sinatra"
require "sinatra/base"
require "sinatra/reloader"
require_relative "lib/memo.rb"

class MemoApp < Sinatra::Base
  configure do
    register Sinatra::Reloader
    enable :method_override
  end

  helpers do
    def h(message)
      Rack::Utils.escape_html(message)
    end

    def replace_newline_with_br(message)
      message.gsub(/\R/, "<br>")
    end

    def title(message)
      message.chomp.split("\n")&.first || "タイトルなし"
    end
  end

  def halt_404_when_doesnt_exist_id(id)
    unless Memo.has_id?(id)
      halt 404, "404 - そのメモはありません"
    end
  end

  get "/" do
    @memos = Memo.memos
    erb :index
  end

  post "/" do
    Memo.insert(params[:message])
    redirect "/"
  end

  get "/new" do
    erb :new
  end

  get "/:id" do
    halt_404_when_doesnt_exist_id(params[:id])
    @message = Memo.message(params[:id])
    erb :show
  end

  get "/:id/edit" do
    halt_404_when_doesnt_exist_id(params[:id])
    @message = Memo.message(params[:id])
    erb :edit
  end

  patch "/:id" do
    halt_404_when_doesnt_exist_id(params[:id])
    Memo.update(params[:id], params[:message])
    redirect "/"
  end

  delete "/:id" do
    halt_404_when_doesnt_exist_id(params[:id])
    Memo.delete(params[:id])
    redirect "/"
  end
end
