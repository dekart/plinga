require 'plinga/rails/controller/url_rewriting'
require 'plinga/rails/controller/redirects'

module Plinga
  module Rails

    # Rails application controller extension
    module Controller
      def self.included(base)
        base.class_eval do
          include Plinga::Rails::Controller::UrlRewriting
          include Plinga::Rails::Controller::Redirects

          helper_method(:plinga, :plinga_params, :plinga_signed_params, :params_without_plinga_data,
            :current_plinga_user, :plinga_canvas?
          )

          helper Plinga::Rails::Helpers
        end
      end

      protected

      PLINGA_PARAM_NAMES = %w{ userid sessionid sessionkey }

      RAILS_PARAMS = %w{ controller action }

      # Accessor to current application config. Override it in your controller
      # if you need multi-application support or per-request configuration selection.
      def plinga
        Plinga::Config.default
      end

      # A hash of params passed to this action, excluding secure information passed by plinga
      def params_without_plinga_data
        params.except(*PLINGA_PARAM_NAMES)
      end

      # params coming directly from plinga
      def plinga_params
        params.except(*RAILS_PARAMS)
      end

      # encrypted plinga params
      def plinga_signed_params
        if plinga_params['sessionid'].present?
          encrypt_params(plinga_params)
        else
          request.env["HTTP_SIGNED_PARAMS"] || request.params['signed_params'] || flash[:signed_params]
        end
      end

      # Accessor to current plinga user. Returns instance of Plinga::User
      def current_plinga_user
        @current_plinga_user ||= fetch_current_plinga_user
      end

      # Did the request come from canvas app
      def plinga_canvas?
        plinga_params['sessionid'].present? || request.env['HTTP_SIGNED_PARAMS'].present? || flash[:signed_params].present?
      end

      private

      def fetch_current_plinga_user
        Plinga::User.from_plinga_params(plinga, plinga_params['sessionid'].present? ? plinga_params : plinga_signed_params)
      end

      def encrypt_params(params)
        key = Digest::MD5.hexdigest("secret_key_#{ plinga.app_id }_#{ plinga.app_secret }")

        encryptor = ActiveSupport::MessageEncryptor.new(key)

        encryptor.encrypt_and_sign(params)
      end

      def decrypt_params(encrypted_params)
        key = Digest::MD5.hexdigest("secret_key_#{ plinga.app_id }_#{ plinga.app_secret }")

        encryptor = ActiveSupport::MessageEncryptor.new(key)

        encryptor.decrypt_and_verify(encrypted_params)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        nil
      end
    end
  end
end