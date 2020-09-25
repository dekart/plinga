module Plinga
  class User
    class InvalidSignature < StandardError; end

    class << self
      # Creates an instance of Plinga::User using application config and request parameters
      def from_plinga_params(config, params)
        params = decrypt(config, params) if params.is_a?(String)

        return unless params && params['userid'] && signature_valid?(config, params)

        new(params)
      end

      def decrypt(config, encrypted_params)
        key = Digest::MD5.hexdigest("secret_key_#{ config.app_id }_#{ config.app_secret }")

        encryptor = ActiveSupport::MessageEncryptor.new(key)

        encryptor.decrypt_and_verify(encrypted_params)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        ::Rails.logger.error "\nError while decoding plinga params: \"#{ encrypted_params }\""

        nil
      end

      def signature_valid?(config, params)
        !params['sessionid'].blank? && params['sessionid'] == auth_key(config, params)
      end

      def auth_key(config, params)
        Digest::MD5.hexdigest(
          [params['userid'], params['sessionkey'], config.app_secret].join('')
        )
      end

      def get_uid(user_id)
        Redis.current.hget('users_relations', user_id)
      end

      def get_or_create_uid(user_id)
        result = Plinga::User.get_uid(user_id)

        unless result
          Redis.current.hset('users_relations', user_id, Redis.current.hlen('users_relations').to_i + 1)

          result = Redis.current.hget('users_relations', user_id)
        end

        result
      end
    end

    def initialize(options = {})
      @options = options
    end

    def authenticated?
      access_token && !access_token.empty?
    end

    def uid
      @options['uid'] ||= Plinga::User.get_or_create_uid(@options['userid'])
    end

    def original_id
      @options['userid']
    end

    def access_token
      @options['sessionid']
    end
  end
end
