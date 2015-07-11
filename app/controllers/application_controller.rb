class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, except: [:spizza]
  require 'open-uri'
  require 'csv'
  require 'json'

  def welcome

  end

  def suggest
    filtered = CSV.read("most_used_10k.csv").select{|row| row[0].start_with? URI.encode(params[:q])}.map{|row| row[0]}
    render json: filtered
  end

  def spizza
    @docs = JSON.load(open("http://localhost:8983/solr/new_core/select?q=#{URI.encode(params[:q])}&wt=json&indent=true&rows=#{(500..700).to_a.sample}"))['response']['docs']
    @spellcheck = JSON.load(open("http://localhost:8983/solr/new_core/spell?wt=json&indent=true&spellcheck=true&spellcheck.q=#{URI.encode(params[:q])}"))['spellcheck']['suggestions'].try(:[], 1).try(:[], 'suggestion').try(:first)
  end

end
