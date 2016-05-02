module Spree
  module Admin
    class VideoSupportSettingsController < Spree::Admin::BaseController

      def edit
        @preferences_video_support_settings = [:video_support_main_api_key, :video_support_alias_api_key]
      end

      def update
        params.each do |name, value|
          next unless Spree::Config.has_preference? name
          Spree::Config[name] = value
        end

        flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:video_support_settings))
        redirect_to edit_admin_video_support_settings_path
      end

    end
  end
end
