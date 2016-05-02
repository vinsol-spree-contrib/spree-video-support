module Spree
  module Support
    class BaseController < Spree::BaseController
      layout '/spree/layouts/support'

      before_action :authorize_support_agent

      private
        def authorize_support_agent
          if respond_to?(:model_class, true) && model_class
            record = model_class
          else
            record = controller_name.to_sym
          end
          authorize! :support_agent, record
          authorize! action, record
        end

        def action
          params[:action].to_sym
        end
    end
  end
end
