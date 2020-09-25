module Plinga
  module Rails
    module Controller
      module Redirects
        protected

        # Redirects user to a definite URL with JavaScript code that overwrites
        # top frame location. Use it to redirect user from within an iframe.
        def redirect_from_iframe(url_options)
          redirect_url = url_options.is_a?(String) ? url_options : url_for(url_options)

          ::Rails.logger.debug "Redirecting from IFRAME to #{ redirect_url }"

          respond_to do |format|
            format.html do
              render(
                :text   => iframe_redirect_html_code(redirect_url),
                :layout => false
              )
            end

            format.js do
              render(
                :text   => iframe_redirect_js_code(redirect_url),
                :layout => false
              )
            end
          end
        end

        # Generates HTML and JavaScript code to redirect user with top frame location
        # overwrite
        #
        # @param target_url   An URL to redirect the user to
        # @param custom_code  A custom HTML code to insert into the result document.
        #                     Can be used to add OpenGraph tags to redirect page code.
        def iframe_redirect_html_code(target_url, custom_code = nil)
          %{
            <html><head>
              <script type="text/javascript">
                window.top.location.href = #{ target_url.to_json };
              </script>
              <noscript>
                <meta http-equiv="refresh" content="0;url=#{ target_url }" />
                <meta http-equiv="window-target" content="_top" />
              </noscript>
              #{ custom_code }
            </head></html>
          }
        end

        # Generates JavaScript code to redirect user
        #
        # @param target_url   An URL to redirect the user to
        def iframe_redirect_js_code(target_url)
          "window.top.location.href = #{ target_url.to_json };"
        end
      end
    end
  end
end