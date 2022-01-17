require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

def is_barber_exists? db, name
  db.execute('select * from barbers where name=?', [name]).length > 0
end

def seed_db db, barbers
  barbers.each do |barber| 
    if !is_barber_exists? db, barber
      db.execute 'INSERT INTO barbers (name) values (?)', [barber]
    end
  end
end

configure do
  db = SQLite3::Database.new 'barbershop.db'
  db.execute 'CREATE TABLE IF NOT EXISTS "users" 
                (
                  "id"	INTEGER PRIMARY KEY AUTOINCREMENT, 
                  "username"	TEXT,	
                  "phone"	TEXT, 
                  "datestamp"	TEXT, 
                  "barber"	TEXT, 
                  "color"	TEXT 
                );'


  db.execute 'CREATE TABLE IF NOT EXISTS "barbers" 
                (
                  "id"	INTEGER PRIMARY KEY AUTOINCREMENT, 
                  "name"	TEXT	
                 );'

  seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Fring', 'Mike Ehrmantraut']
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

  hh = {
          :phone => 'Enter your phone',
          :datetime => 'Enter Date and Time'
  }

  @error = hh.select {|key, _| params[key] == ''}.values.join(', ')

  if @error != ''
    return erb :visit
  end

  db = get_db
  db.execute 'INSERT INTO users 
            (
              username, 
              phone, 
              datestamp, 
              barber, 
              color
            )
      VALUES (?, ?, ?, ?, ?)',
      [@username, @phone, @datetime, 
       @barber, @color]

  erb "Ok, username is #{@username}!, #{@phone}, #{@datetime}, #{@barber}, #{@color}"
end

get '/showusers' do
  db = get_db
  @results = db.execute 'select * from users order by id desc'
  erb :showusers
end

post '/contacts' do
  require 'pony'

  Pony.mail(
    :name => params[:username],
    :mail => params[:useremail],
    :body => params[:textbody],
    :to => 'nozimy@yandex.ru',
    :subject => params[:username] + ' has contacted you',
    :body => params[:textbody],
    :port => '465',
    :via => :smtp,
    :via_options => {
      :address              => 'smtp.yandex.ru',
      :port                 => '25',
      :enable_starttls_auto => true,
      :user_name            => 'Nozim',
      :password             => 'Naut1lu$',
      :authentication       => :plain
 })
end


