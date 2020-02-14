# frozen_string_literal: true

require "sinatra"
require "sinatra/base"
require "sinatra/reloader"
require "securerandom"

class MemoApp < Sinatra::Base
  configure do
    register Sinatra::Reloader
    enable :method_override
  end

  def get_memo_titles
    get_memo_paths.map do |path|
      File.open("#{path}", "r") { |f| f.gets }
    end
  end

  def get_memo_paths
    Dir.glob("texts/*").sort_by { |f| File.mtime(f) }.reverse
  end

  def create_memo
    filename = create_filename
    File.open("texts/#{filename}.txt", "w") do |f|
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

  def valid_memo_check(path)
    if valid_filename_check(path)
      halt 404, "404 - そのメモはありません"
    end
  end

  def create_filename
    filename = SecureRandom.urlsafe_base64
    while valid_filename_check(filename)
      filename = SecureRandom.urlsafe_base64
    end
    filename
  end

  def valid_filename_check(path)
    FileTest.exist?("texts/#{path}.txt")
  end

  def set_path
    "texts/" + params[:filename] + ".txt"
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  get "/" do
    @titles = get_memo_titles
    @paths = get_memo_paths
    erb :index
  end

  post "/" do
    create_memo
    redirect "/"
  end

  get "/new" do
    erb :new
  end

  get "/:filename" do
    @path = set_path
    valid_memo_check(@path)
    erb :show
  end

  get "/:filename/edit" do
    @path = set_path
    valid_memo_check(@path)
    erb :edit
  end

  patch "/:filename" do
    @path = set_path
    valid_memo_check(@path)
    write_memo(@path)
    redirect "/"
  end

  delete "/:filename" do
    @path = set_path
    valid_memo_check(@path)
    delete_memo(@path)
    redirect "/"
  end
end
