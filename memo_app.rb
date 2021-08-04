# frozen_string_literal: true

require 'erb'
require 'sinatra'
require 'sinatra/reloader'

class Memo
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

  def to_hash
    hash = {}
    instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
    hash
  end

  def self.create(title, content)
    memo = Memo.new(title, content)
    registar_to_json(memo, memo.id)
  end

  def self.show_all
    sorted_files = Dir.glob('db/*').sort_by { |json_file| File.birthtime(json_file) }
    sorted_files.map do |json_file|
      File.open(json_file) { |json_data| JSON.parse(json_data.read) }
    end
  end

  def self.update(id, title, content)
    memo = Memo.find(id)
    memo['title'] = title
    memo['content'] = content
    registar_to_json(memo, id)
  end

  def self.delete(id)
    Dir.glob('db/*') do |json_file|
      File.delete(json_file) if json_file == "db/#{id}.json"
    end
  end
end

def registar_to_json(memo, id)
  memo_hash = memo.to_hash
  File.open("db/#{id}.json", 'w') do |file|
    JSON.dump(memo_hash, file)
  end
end

get '/memos' do
  @memo_array = Memo.show_all
  erb :index
end

post '/memos' do
  Memo.create(h(params['title']), h(params['content']))
  redirect '/memos'
  erb :index
end

get '/memos/new' do
  erb :form
end

get '/memos/:id' do
  @memo = Memo.find(h(params['id']))
  erb :content
end

get '/memos/:id/edit' do
  @memo = Memo.find(h(params['id']))
  erb :edit
end

patch '/memos/:id' do
  Memo.update(h(params['id']), h(params['title']), h(params['content']))
  redirect '/memos'
  erb :index
end

delete '/memos/:id' do
  Memo.delete(h(params['id']))
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
