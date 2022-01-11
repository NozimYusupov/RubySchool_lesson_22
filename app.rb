require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about' do
  erb :about
end

get '/contacts' do
  erb :contacts
end

get '/visit' do
  erb :visit
end

post '/visit' do 
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber] 
  @color = params[:color]

  if @username == ''
    @error = 'Enter your name'
    return erb :visit
  end

  erb "Ok, username is {@username}!, #{@phone}, #{@datetime}, #{@barber}, #{@color}"
end


get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
