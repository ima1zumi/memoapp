# frozen_string_literal: true

require "sinatra"
require "sinatra/base"
require "sinatra/reloader"

class MemoApp < Sinatra::Base
  configure do
    register Sinatra::Reloader
    enable :method_override
  end

  def get_memo_titles
    Dir.glob("texts/*").sort.map do |path|
      File.open("#{path}", "r") { |f| f.gets }
    end
  end

  def get_memo_paths
    Dir.glob("texts/*").sort
  end

  def create_memo
    File.open("texts/#{Time.now.to_i}.txt", "w") do |f|
      f.write(h(params[:message]))
    end
  end

  def write_memo(path)
    File.open("#{path}", "w") do |f|
      f.write(h(params[:message]))
    end
  end

  def delete_memo(path)
    File.delete("#{path}")
  end

  def valid_memo_check(memo)
    if memo.nil?
      halt 404, "404 - そのメモはありません"
    end
  end

  def set_path
    paths = get_memo_paths
    paths[params[:num].to_i]
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  get "/" do
    @titles = get_memo_titles
    erb :index
  end

  post "/" do
    create_memo
    redirect "/"
  end

  get "/new" do
    erb :new
  end

  get "/:num" do
    @path = set_path
    valid_memo_check(@path)
    erb :show
  end

  get "/:num/edit" do
    @path = set_path
    valid_memo_check(@path)
    erb :edit
  end

  patch "/:num" do
    @path = set_path
    valid_memo_check(@path)
    write_memo(@path)
    redirect "/"
  end

  delete "/:num" do
    @path = set_path
    valid_memo_check(@path)
    delete_memo(@path)
    redirect "/"
  end
end
