require 'plinga/rails/helpers/url_helper'

module Plinga
  module Rails
    module Controller
      module UrlRewriting
        include Plinga::Rails::Helpers::UrlHelper

        def self.included(base)
          base.class_eval do
            helper_method(:exe_canvas_page_url, :exe_callback_url)
          end
        end

        protected

        # A helper to generate an URL of the application canvas page URL
        #
        # @param protocol A request protocol, should be either 'http://' or 'https://'.
        #                 Defaults to current protocol.
        def plinga_canvas_page_url(protocol = nil)
          plinga.canvas_page_url(protocol || request.protocol)
        end

        # A helper to generate an application callback URL
        #
        # @param protocol A request protocol, should be either 'http://' or 'https://'.
        #                 Defaults to current protocol.
        def plinga_callback_url(protocol = nil)
          plinga.callback_url(protocol || request.protocol)
        end
      end
    end
  end
end
