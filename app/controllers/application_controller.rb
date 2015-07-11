class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, except: [:spizza]
  require 'open-uri'
  require 'csv'
  require 'json'
  require 'neography'

  before_filter :connect_neo4j

  def welcome

  end

  def suggest
    filtered = CSV.read("most_used_10k.csv").select{|row| row[0].start_with? URI.encode(params[:q])}.map{|row| row[0]}
    render json: filtered
  end

  def spizza
    query = "MATCH (p)-[r:tag_count]-(n:Tag) WHERE n.name = '#{params['q']}' WITH p, r ORDER BY r.count desc RETURN p.username, r.count"
    @results = @neo.execute_query(query)['data']

    @images = JSON.load(open("https://api.instagram.com/v1/tags/#{params['q']}/media/recent?client_id=9d5a15aab64f407c941c470fad47c289"))['data']
  end


  def connect_neo4j
    Neography.configure do |config|
      config.protocol             = "http"
      config.server               = "52.17.242.13"
      config.port                 = 7474
      config.directory            = ""  # prefix this path with '/'
      config.cypher_path          = "/cypher"
      config.gremlin_path         = "/ext/GremlinPlugin/graphdb/execute_script"
      config.log_file             = "neography.log"
      config.log_enabled          = false
      config.slow_log_threshold   = 0    # time in ms for query logging
      config.max_threads          = 20
      config.authentication       = nil  # 'basic' or 'digest'
      config.username             = 'neo4j'
      config.password             = 'password'
      config.parser               = MultiJsonParser
      config.http_send_timeout    = 1200
      config.http_receive_timeout = 1200
      config.persistent           = true
      end

    @neo ||= Neography::Rest.new
  end

end
