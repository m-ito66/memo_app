# frozen_string_literal: true

require 'erb'
require 'sinatra'
require 'sinatra/reloader'

get '/memos' do
  @memo = load_data
  erb :index
end

post '/memos' do
  hash = load_data
  params['id'] = hash['memos'].count + 1
  hash['memos'] << escape(params)
  enter_data(hash)
  redirect '/memos'
  erb :index
end

get '/memos/new' do
  erb :form
end

get '/memos/:id' do
  memos = load_data
  read_memo_data(memos)
  erb :content
end

get '/memos/:id/edit' do
  memos = load_data
  read_memo_data(memos)
  erb :edit
end

patch '/memos/:id' do
  memos = load_data
  escaped_params = escape(params)
  memos['memos'].each do |memo|
    if memo['id'] == escaped_params['id']
      memo['title'] = escaped_params['title']
      memo['content'] = escaped_params['content']
    end
  end
  enter_data(memos)
  redirect '/memos'
  erb :index
end

delete '/memos/:id' do
  memos = load_data
  memos['memos'].each do |memo|
    memo['id'] = nil if memo['id'] == params['id']
  end
  enter_data(memos)
  redirect '/memos'
  erb :index
end

helpers do
  include ERB::Util
  def escape(params)
    keys = params.keys
    values = params.values.map do |value|
      escape_html(value)
    end
    alist = keys.zip(values)
    Hash[alist]
  end
end

def load_data
  File.open('db/data.json') { |file| JSON.parse(file.read) }
end

def enter_data(data)
  File.open('db/data.json', 'w') do |file|
    JSON.dump(data, file)
  end
end

def read_memo_data(memos)
  memos['memos'].each do |memo|
    next unless memo['id'] == params['id'].to_s

    @id = memo['id']
    @title = memo['title']
    @content = memo['content']
  end
end
