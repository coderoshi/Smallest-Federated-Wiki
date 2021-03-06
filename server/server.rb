require 'rubygems'
require 'pathname'
require 'bundler'
require 'mongo'
Bundler.require

class Controller < Sinatra::Base
  root_path = File.dirname(File.dirname(__FILE__))
  APP_ROOT = Pathname.new(root_path).realpath.to_s #find full path to this file

  set :port, 1111
  set :public, "#{APP_ROOT}/client"
  set :views , "#{APP_ROOT}/server/views"  
  set :haml, :format => :html5
  
  # mongo connection
  def self.db
    @@conn ||= Mongo::Connection.new
    @@db ||= @@conn['wiki']
    @@coll ||= @@db['wiki']
  end
  
  helpers do
    def gen_id
      (0..15).collect{(rand*16).to_i.to_s(16)}.join
    end
    def get_page name
      val = Controller.db.find({:title => name}).first
      put_page name, {'title'=>name, 'story'=>[{'type'=>'factory', 'id'=>gen_id}]} unless val
      val
      # path = File.join(APP_ROOT, "data/pages/#{name}")
      # return put_page name, {'title'=>name,'story'=>[{'type'=>'factory', 'id'=>gen_id}]} unless File.file? path
      # File.open(path, 'r') { |file| JSON.parse(file.read) }
    end
    def put_page name, page
      Controller.db.save(page.merge({'_id' => name}))
      # File.open(File.join(APP_ROOT, "data/pages/#{name}"), 'w') { |file| file.write(JSON.generate(page)) }
      return page
    end
    def resolve_links string
      string.
        gsub(/\[\[([^\]]+)\]\]/i) {
                    |name| 
                    name.gsub!(/^\[\[(.*)\]\]/, '\1')

                    slug = name.gsub(/\s/, '-')
                    slug = slug.gsub(/[^A-Za-z0-9-]/, '').downcase
                    '<a class="internal" href="/'+slug+'.html" data-page-name="'+slug+'">'+name+'</a>'
                }.
        gsub(/\[(http.*?) (.*?)\]/i, '<a class="external" href="\1">\2</a>')
    end
  end

  configure do
    `cd #{APP_ROOT}/data/status; cp default-local-identity local-identity` unless File.exists? File.join(APP_ROOT,'data/status/local-identity')
    $identity = File.open(File.join(APP_ROOT, "data/status/local-identity"), 'r') { |file| JSON.parse(file.read) }
    `cd #{APP_ROOT}/data/pages; cp default-welcome-visitors welcome-visitors` unless File.exists? File.join(APP_ROOT,'data/pages/welcome-visitors')
    `cd #{APP_ROOT}/client; cp default-favicon.png favicon.png` unless File.exists? File.join(APP_ROOT,'client/favicon.png')
  end

  get '/style.css' do
    content_type 'text/css'
    sass :style
  end

  get '/' do
    haml :page, :locals => { :page => get_page($identity['root']), :page_name => $identity['root'] }
  end

  get %r{^/([a-z0-9-]+)\.html$} do |name|
    haml :page, :locals => { :page => get_page(name), :page_name => name }
  end
  get %r{^/view/([a-z0-9-]+(/view/[a-z0-9-]+)*)$} do |pages,extra|
    haml :view, :locals => {:page_names => pages.split('/view/')}
  end

  get %r{^/([a-z0-9-]+)\.json$} do |name|
    content_type 'application/json'
    JSON.pretty_generate(get_page(name))
  end

  put %r{^/page/([a-z0-9-]+)/action$} do |name|
    page = get_page name
    action = JSON.parse params['action']
    puts action.inspect
    case action['type']
    when 'move'
      page['story'] = action['order'].collect{ |id| page['story'].detect{ |item| item['id'] == id } }
    when 'add'
      before = action['after'] ? 1+page['story'].index{|item| item['id'] == action['after']} : 0
      page['story'].insert before, action['item']
    when 'remove'
      page['story'].delete_at page['story'].index{ |item| item['id'] == action['id'] }
    when 'edit'
      page['story'][page['story'].index{ |item| item['id'] == action['id'] }] = action['item']
    else
      puts "unfamiliar action: #{action.inspect}"
      status 501
      return "unfamiliar action"
    end
    ( page['journal'] ||= [] ) << action # todo: journal undo, not redo
    put_page name, page
    "ok"
  end

  get %r{^/remote/([a-zA-Z0-9:\.-]+)/([a-z0-9-]+)\.json$} do |site, name|
    content_type 'application/json'
    `curl -s #{site}/#{name}.json`
  end

  get %r{^/remote/([a-zA-Z0-9:\.-]+)/favicon.png$} do |site|
    content_type 'image/png'
    `curl -s #{site}/favicon.png`
  end

end
