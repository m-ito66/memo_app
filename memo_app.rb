# frozen_string_literal: true

require 'erb'
require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class Memo
  @conn = PG.connect(dbname: 'memo_app')
  def self.find(params)
    @conn.exec('SELECT * FROM memos WHERE id =$1', [params[:id]]).first
  end

  def self.create(params)
    @conn.exec('INSERT INTO memos(title, content) VALUES ($1, $2)', [params[:title], params[:content]])
  end

  def self.show_all
    @conn.exec('SELECT * FROM memos')
  end

  def self.update(params)
    @conn.exec('UPDATE memos SET title=$1, content=$2 WHERE id=$3', [params[:title], params[:content], params[:id]])
  end

  def self.delete(params)
    @conn.exec('DELETE FROM memos WHERE id=$1', [params[:id]])
  end
end

get '/memos' do
  @memo_array = Memo.show_all
  erb :index
end

post '/memos' do
  Memo.create(params)
  redirect '/memos'
  erb :index
end

get '/memos/new' do
  erb :form
end

get '/memos/:id' do
  @memo = Memo.find(params)
  erb :content
end

get '/memos/:id/edit' do
  @memo = Memo.find(params)
  erb :edit
end

patch '/memos/:id' do
  Memo.update(params)
  redirect '/memos'
  erb :index
end

delete '/memos/:id' do
  Memo.delete(params)
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
