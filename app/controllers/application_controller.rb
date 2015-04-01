class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, except: [:spizza]
  require 'open-uri'

  def welcome

  end

  def suggest
    render json: JSON.load(open("http://localhost:8983/solr/new_core/suggest?q=#{params[:q]}&wt=json&indent=true"))['spellcheck']['suggestions'][1]['suggestion'].reject{|v| ['jsonp', 'jsonline'].include?(v)}.map{|v| {value: v}}
  end

  def spizza
    @docs = JSON.load(open("http://localhost:8983/solr/new_core/select?q=#{params[:q]}&wt=json&indent=true&rows=#{(500..700).to_a.sample}"))['response']['docs']
    @spellcheck = JSON.load(open("http://localhost:8983/solr/new_core/spell?wt=json&indent=true&spellcheck=true&spellcheck.q=#{params[:q]}"))['spellcheck']['suggestions'].try(:[], 1).try(:[], 'suggestion').try(:first)
  end

end
