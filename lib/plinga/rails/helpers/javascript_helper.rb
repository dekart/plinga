module Plinga
  module Rails
    module Helpers
      module JavascriptHelper
        # A helper to integrate Vkontakte JS Api to the current page. Generates a
        # JavaScript code that initializes Javascript client for the current application.
        #
        # @param &block   A block of JS code to be inserted in addition to client initialization code.
        def plinga_connect_js()
          js = <<-JAVASCRIPT
            <script type="text/javascript" src="https://s3.amazonaws.com/imgs3.plinga.de/general/easyXDM.min.js">
            </script>
            <script type="text/javascript">
                easyXDM.DomHelper.requiresJSON("https://s3.amazonaws.com/imgs3.plinga.de/general/json2.min.js");
            </script>
            <script type="text/javascript" src="https://s3.amazonaws.com/imgs3.plinga.de/plingaRpc/plingaRpc.js">
            </script>
          JAVASCRIPT

          js.html_safe
        end
      end
    end
  end
end
