class Spree::VideoSupportRequestController < Spree::BaseController
  before_action :load_ticket, only: [:close, :active]

  def create
    initialize_ticket
    is_existing_ticket = @video_ticket.persisted?

    if is_existing_ticket || @video_ticket.save
      session[:active_video_ticket_id] = @video_ticket.id
      session[:customer_email] = permitted_video_request_params['customer_email']
      render json: { success: true, ticket_unique_id: @video_ticket.unique_id, existing: is_existing_ticket }, status: 200
    else
      render json: { success: false, errors: @video_ticket.errors.full_messages.to_sentence }, status: 400
    end
  end

  def active
    render json: { success: true, ticket_unique_id: @video_ticket.unique_id }, status: 200
  end

  def close
    if @video_ticket.end(try_spree_current_user || session[:customer_email])
      session[:active_video_ticket_id] = nil
      render json: { success: true, ticket_unique_id: @video_ticket.unique_id }, status: 200
    else
      render json: { success: false, errors: @video_ticket.errors.full_messages.to_sentence }, status: 400
    end
  end

  private
    def permitted_video_request_params
      if try_spree_current_user.present?
        params.require(:spree_chat).permit(:purpose)
      else
        # TODO: move to permitted attributes
        params.require(:spree_chat).permit(:customer_first_name, :customer_last_name, :customer_email, :purpose)
      end
    end

    def initialize_ticket
      if try_spree_current_user.present?
        @video_ticket = try_spree_current_user.active_support_request.presence || \
                        try_spree_current_user.build_active_support_request(permitted_video_request_params)
      else
        @video_ticket = Spree::SupportTicket.find_by(id: session[:active_video_ticket_id])
        @video_ticket ||= Spree::SupportTicket.new(permitted_video_request_params) unless @video_ticket.try(:active?)
      end
    end

    def load_ticket
      @video_ticket = try_spree_current_user.try(:active_support_request)
      @video_ticket ||= Spree::SupportTicket.find_by(id: session[:active_video_ticket_id])
      if @video_ticket.blank? || !@video_ticket.active?
        session[:active_video_ticket_id] = nil
        render json: { success: false, errors: 'No active ticket found' }, status: 404
      end
    end
end
