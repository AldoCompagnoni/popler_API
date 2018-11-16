require 'bundler/setup'
%w(yaml json csv digest).each { |req| require req }
Bundler.require(:default)
require 'sinatra'
require 'multi_json'
require "sinatra/multi_route"
require 'yaml'
require "pg"
require 'active_record'
require 'active_support'

require_relative 'funs'
require_relative "models"

# feature flag: toggle redis
$use_redis = false

$redis = Redis.new host: ENV.fetch('REDIS_PORT_6379_TCP_ADDR', 'localhost'),
                   port: ENV.fetch('REDIS_PORT_6379_TCP_PORT', 6379)

$config = YAML::load_file(File.join(__dir__, ENV['RACK_ENV'] == 'test' ? 'test_config.yaml' : 'config.yaml'))
ActiveSupport::Deprecation.silenced = true
ActiveRecord::Base.establish_connection($config['db'])
ActiveRecord::Base.logger = Logger.new(STDOUT)

class PopAPI < Sinatra::Application
  register Sinatra::MultiRoute

  before do
  #   # puts '[ENV]'
  #   # p ENV
  #   puts '[Params]'
  #   p params
  #   # puts '[body]'
  #   # p JSON.parse(request.body.read)
  
    # use redis caching
    if $config['caching'] && $use_redis
      # if request.path_info != "/"
      if !["/", "/heartbeat", "/docs"].include? request.path_info
        @cache_key = Digest::MD5.hexdigest(request.url)
        if $redis.exists(@cache_key)
          headers 'Cache-Hit' => 'true'
          halt 200, {
            'Content-Type' => 'application/json; charset=utf8',
            'Access-Control-Allow-Methods' => 'HEAD, GET',
            'Access-Control-Allow-Origin' => '*'},
            $redis.get(@cache_key)
        end
      end
    end
  end

  after do
    # cache response in redis
    if $config['caching'] &&
      $use_redis &&
      !response.headers['Cache-Hit'] &&
      response.status == 200 &&
      request.path_info != "/" &&
      request.path_info != "/heartbeat" &&
      request.path_info != "/docs" &&
      request.path_info != ""

      $redis.set(@cache_key, response.body[0], ex: $config['caching']['expires'])
    end
  end

  ## configuration
  configure do
    set :raise_errors, false
    set :show_exceptions, false
    set :strict_paths, false
    set :server, :puma
    set :protection, :except => [:json_csrf]
  end

  # halt: error helpers
  not_found do
    halt 404, {'Content-Type' => 'application/json'}, JSON.generate({ 'error' => 'route not found' })
  end

  error 405 do
    halt 405, {'Content-Type' => 'application/json'}, JSON.generate({ 'error' => 'Method Not Allowed' })
  end

  error 500 do
    halt 500, {'Content-Type' => 'application/json'}, JSON.generate({ 'error' => 'server error' })
  end

  # headers
  helpers do
    def headers_get
      headers "Content-Type" => "application/json; charset=utf8"
      headers "Access-Control-Allow-Methods" => "HEAD, GET"
      headers "Access-Control-Allow-Origin" => "*"
      cache_control :public, :must_revalidate, :max_age => 60
    end

    def serve_data(ha, data)
      # puts '[CONTENT_TYPE]'
      # puts request.env['CONTENT_TYPE'].nil?
      case request.env['CONTENT_TYPE']
      when 'application/json'
        ha.to_json
      when 'text/csv'
        to_csv(data)
      when nil
        ha.to_json
      else
        halt 415, { error: 'Unsupported media type', message: 'supported media types are application/json and text/csv; no Content-type equals application/json' }.to_json
      end
    end
  end

  ## routes
  get '/' do
    headers_get
    redirect '/heartbeat'
  end

  get '/docs' do
    headers_get
    redirect 'https://github.com/AldoCompagnoni/popler_API', 301
  end

  get "/heartbeat" do
    headers_get
    $ip = request.ip
    return JSON.pretty_generate({
      "routes" => [
        "/docs (GET)",
        "/heartbeat (GET)",
        # "/biomass (GET)",
        "/summary (GET)",
        "/search (GET)"
      ]
    })
  end

  # routes for testing
  # get '/biomass' do
  #   headers_get
  #   begin
  #     data = Biomass.endpoint(params)
  #     raise Exception.new('no results found') if data.length.zero?
  #     ha = { count: data.limit(nil).count(1), returned: data.length, data: data, error: nil }
  #     serve_data(ha, data)
  #   rescue Exception => e
  #     halt 400, { count: 0, returned: 0, data: nil, error: { message: e.message }}.to_json
  #   end
  # end

  # get '/search' do
  #   headers_get
  #   begin
  #     data = Search.endpoint(params)
  #     raise Exception.new('no results found') if data.length.zero?
  #     ha = { count: data.limit(nil).count(1), returned: data.length, data: data, error: nil }
  #     serve_data(ha, data)
  #   rescue Exception => e
  #     halt 400, { count: 0, returned: 0, data: nil, error: { message: e.message }}.to_json
  #   end
  # end



  # real routes
  get '/summary' do
    headers_get
    begin
      data = Summary.endpoint(params)
      raise Exception.new('no results found') if data.length.zero?
      ha = { count: data.limit(nil).count(1), returned: data.length, data: data, error: nil }
      serve_data(ha, data)
    rescue Exception => e
      halt 400, { count: 0, returned: 0, data: nil, error: { message: e.message }}.to_json
    end
  end

  get '/search' do
    headers_get
    begin
      data = Search.endpoint(params)
      raise Exception.new('no results found') if data.length.zero?
      ha = { count: data.limit(nil).count(1), returned: data.length, data: data, error: nil }
      serve_data(ha, data)
    rescue Exception => e
      halt 400, { count: 0, returned: 0, data: nil, error: { message: e.message }}.to_json
    end
  end



  # prevent some HTTP methods
  route :post, :put, :delete, :copy, :patch, :options, :trace, '/*' do
    halt 405
  end

end
