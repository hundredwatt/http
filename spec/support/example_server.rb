require 'webrick'

class ExampleService < WEBrick::HTTPServlet::AbstractServlet
  PORT = 65432 # rubocop:disable NumericLiterals

  def do_GET(request, response) # rubocop:disable MethodName
    case request.path
    when '/'
      response.status = 200

      case request['Accept']
      when 'application/json'
        response['Content-Type'] = 'application/json'
        response.body = '{"json": true}'
      else
        response['Content-Type'] = 'text/html'
        response.body   = '<!doctype html>'
      end
    when '/params'
      if request.query_string = 'foo=bar'
        response.status = 200
        response.body     = 'Params!'
      end
    when '/not-found'
      response.body   = 'not found'
      response.status = 404
    when '/redirect-301'
      response.status = 301
      response['Location'] = "http://127.0.0.1:#{PORT}/"
    when '/redirect-302'
      response.status = 302
      response['Location'] = "http://127.0.0.1:#{PORT}/"
    else
      response.status = 404
    end
  end

  def do_POST(request, response) # rubocop:disable MethodName
    case request.path
    when '/form'
      if request.query['example'] == 'testing-form'
        response.status = 200
        response.body   = 'passed :)'
      else
        response.status = 400
        response.body   = 'invalid! >:E'
      end
    when '/body'
      if request.body == 'testing-body'
        response.status = 200
        response.body   = 'passed :)'
      else
        response.status = 400
        response.body   = 'invalid! >:E'
      end
    else
      response.status = 404
    end
  end

  def do_HEAD(request, response) # rubocop:disable MethodName
    case request.path
    when '/'
      response.status = 200
      response['Content-Type'] = 'text/html'
    else
      response.status = 404
    end
  end
end

ExampleServer = WEBrick::HTTPServer.new(:Port => ExampleService::PORT, :AccessLog => [])
ExampleServer.mount '/', ExampleService

t = Thread.new { ExampleServer.start }
trap('INT') do
  ExampleServer.shutdown
  exit
end

Thread.pass while t.status && t.status != 'sleep'
