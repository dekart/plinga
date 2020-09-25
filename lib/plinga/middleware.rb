# This rack middleware converts POST requests from Wizq to GET requests.
# It's necessary to make RESTful routes work as expected without any changes
# in the application.
module Plinga
  class Middleware
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      request = ::Rack::Request.new(env)

      if (request.POST['access_token'] || request.POST['signed_params']) && request.post? && request.params['_method'].blank?
        env['REQUEST_METHOD'] = 'GET'
      end

      # Put signed_params parameter to the same place where HTTP header X-Signed-Params come.
      # This let us work both with params and HTTP headers in the same way. Very useful for AJAX.
      env['HTTP_SIGNED_PARAMS'] ||= request.POST['signed_params']

      response, headers, body = @app.call(env)
      headers['P3P'] = %{CP="NOI DSP COR NID ADMa OPTa OUR NOR"}

      [response, headers, body]
    end
  end
end
