class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, except: [:spizza]
  require 'open-uri'

  def welcome

  end

  def suggest
    render json: JSON.load(open("http://localhost:8983/solr/new_core/suggest?q=#{params[:q]}&wt=json&indent=true"))['spellcheck']['suggestions'][1]['suggestion'].map{|v| {value: v}}
  end

  def spizza
    @docs = JSON.load(open("http://localhost:8983/solr/new_core/select?q=#{params[:q]}&wt=json&indent=true&rows=#{(500..700).to_a.sample}"))['response']['docs']
  end

end
