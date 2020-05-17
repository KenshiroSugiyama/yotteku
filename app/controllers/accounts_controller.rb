class AccountsController < ApplicationController
    def create
      super do |decoded_token|
        User.create(
          email: decoded_token['decoded_token'][:payload]['email'],
          uid:   decoded_token['uid']
        )
      end
    end
end
