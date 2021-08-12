# frozen_string_literal: true

require 'erb'
require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'

class Memo
  attr_accessor :id
  attr_reader :title, :content

  def initialize(title, content)
    @id = SecureRandom.hex
    @title = title
    @content = content
  end

  def self.find(id)
    Dir.glob('db/*') do |json_file|
      memo = File.open(json_file) { |file| JSON.parse(file.read) }
      return memo if memo['id'] == id
    end
  end

  def self.create(title, content)
    memo = Memo.new(title, content)
    save_to_file(memo)
  end

  def self.show_all
    sorted_files = Dir.glob('db/*').sort_by { |json_file| File.birthtime(json_file) }
    sorted_files.map do |json_file|
      File.open(json_file) { |json_data| JSON.parse(json_data.read) }
    end
  end

  def self.update(id, title, content)
    memo = Memo.new(title, content)
    memo.id = id
    save_to_file(memo)
  end

  def self.delete(id)
    Dir.glob('db/*') do |json_file|
      File.delete(json_file) if json_file == "db/#{id}.json"
    end
  end

  def self.to_h(memo)
    { id: memo.id, title: memo.title, content: memo.content }
  end

  def self.save_to_file(memo)
    memo_hash = to_h(memo)
    File.open("db/#{memo.id}.json", 'w') do |file|
      JSON.dump(memo_hash, file)
    end
  end
end

get '/memos' do
  @memo_array = Memo.show_all
  erb :index
end

post '/memos' do
  Memo.create(params['title'], params['content'])
  redirect '/memos'
  erb :index
end

get '/memos/new' do
  erb :form
end

get '/memos/:id' do
  @memo = Memo.find(params['id'])
  erb :content
end

get '/memos/:id/edit' do
  @memo = Memo.find(params['id'])
  erb :edit
end

patch '/memos/:id' do
  Memo.update(params['id'], params['title'], params['content'])
  redirect '/memos'
  erb :index
end

delete '/memos/:id' do
  Memo.delete(params['id'])
  redirect '/memos'
  erb :index
end

not_found do
  '404 ファイルが存在しません'
end

helpers do
  include ERB::Util
  def h(value)
    escape_html(value)
  end
end
