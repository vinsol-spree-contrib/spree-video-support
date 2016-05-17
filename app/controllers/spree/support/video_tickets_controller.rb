class Spree::Support::VideoTicketsController < Spree::Support::BaseController
  before_action :load_video_ticket, only: [:show, :update, :start, :destroy]
  before_action :check_ticket_owner, only: [:start, :destroy]
  before_action :check_pickable_ticket, only: :update
  before_action :check_ticket_active, only: :start

  def show
  end

  def index
    @tickets = Spree::SupportTicket.active
  end

  def update
    if @video_ticket.update(support_agent: try_spree_current_user)
      redirect_to support_video_ticket_path(@video_ticket)
    else
      render :show
    end
  end

  # JSON
  def start
    if @video_ticket.start
      render json: { success: true, ticket_unique_id: @video_ticket.unique_id }, status: 200
    else
      render json: { success: false, errors: @video_ticket.errors.full_messages.to_sentence }, status: 400
    end
  end

  def destroy
    if @video_ticket.end(try_spree_current_user)
      respond_to do |format|
        format.html { redirect_to support_video_ticket_path(@video_ticket) }
        format.json { render json: { success: true }, status: 200 }
      end
    else
      respond_to do |format|
        format.html { render :show }
        format.json { render json: { success: false }, status: 400 }
      end
    end
  end

  def history
    @tickets = Spree::SupportTicket.inactive
  end

  private
    def model_class
      Spree::SupportTicket
    end

    def load_video_ticket
      @video_ticket = Spree::SupportTicket.find(params[:id])
    end

    def check_ticket_owner
      unless @video_ticket.owner?(try_spree_current_user)
        flash[:alert] = 'Only ticket owner can perform this action'
        redirect_to support_video_ticket_path(@video_ticket)
      end
    end

    def check_pickable_ticket
      if !@video_ticket.active? || !@video_ticket.pickable?
        flash[:alert] = 'Ticket is already assigned to somebody else or is alread closed'
        redirect_to support_video_ticket_path(@video_ticket)
      end
    end

    def check_ticket_active
      if !@video_ticket.active?
        flash[:alert] = 'Ticket is not active'
        redirect_to support_video_ticket_path(@video_ticket)
      end
    end

end
