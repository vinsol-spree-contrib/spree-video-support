class Spree::SupportTicket < Spree::Base
  # -------------------------------------------------------------------------------------------------------------------
  # Section For Associations
  # -------------------------------------------------------------------------------------------------------------------
  belongs_to :support_agent, class_name: Spree.user_class
  belongs_to :user

  # -------------------------------------------------------------------------------------------------------------------
  # Section for validations
  # -------------------------------------------------------------------------------------------------------------------
  validate :support_agent_role
  # TODO: validate support agent has only one active ticket
  validates :customer_first_name, :customer_email, presence: true, if: -> { user.blank? }
  validates :purpose, presence: true

  # -------------------------------------------------------------------------------------------------------------------
  # Section for callbacks
  # -------------------------------------------------------------------------------------------------------------------
  before_validation :assign_user_attributes, if: -> { user.present? }
  before_create :assign_unique_id, if: -> { unique_id.blank? }

  # -------------------------------------------------------------------------------------------------------------------
  # Section for scopes
  # -------------------------------------------------------------------------------------------------------------------
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: [nil, false]) }

  # -------------------------------------------------------------------------------------------------------------------
  # Section For Instance Methods
  # -------------------------------------------------------------------------------------------------------------------
  # In seconds
  def active_duration
    return 0 if support_started_at.blank?
    days = (support_ended_at.present? ? (support_ended_at - support_started_at) : (DateTime.current - support_started_at))
    (days * 24 * 60 * 60).to_i
  end

  def status
    if !active?
      closed? ? 'Resolved' : 'Unresolved'
    elsif pickable?
      'Unassigned'
    elsif in_progress?
      'In Progress'
    else
      "Assigned"
    end
  end

  # Starts the support session
  def start
    (errors[:base] << 'Support agent must be present to start the ticket' and return false) if support_agent.blank?
    # Make sure that if a ticket is started again, our start time is unmodified
    touch(:support_started_at) if !support_started_at
    true
  end

  # Ends the support session
  def end(user_or_email)
    if user_or_email.is_a? String
      self.closed_by_email = user_or_email
    elsif user_or_email.is_a? Fixnum
      self.closed_by_id = user_or_email
    else
      self.closed_by_id = user_or_email.try(:id)
    end
    self.support_ended_at = DateTime.current
    self.active = false
    save
  end

  def customer_name
    (customer_first_name.to_s + ' ' + customer_last_name.to_s).presence || "Customer #{ id }"
  end

  def pickable?
    active? && support_agent.blank?
  end

  def owner?(agent)
    !!(support_agent && agent && support_agent.id == agent.id)
  end

  # When assigned to agent and in open state
  def open?
    support_agent.present? && active? && !support_ended_at
  end

  # When ticket is closed successfully
  def closed?
    support_agent.present? && !active? && !!support_ended_at
  end

  def in_progress?
    open? && !!support_started_at
  end

  # ----------------|--------------------------------------------------------------------------------------------------
  # Private Section |
  # ----------------|--------------------------------------------------------------------------------------------------
  private
    def assign_user_attributes
      self.customer_first_name = user.try(:first_name)
      self.customer_last_name  = user.try(:last_name)
      self.customer_email      = user.try(:email)
    end

    def assign_unique_id
      self.unique_id = SecureRandom.hex
    end

    def support_agent_role
      if support_agent && !support_agent.has_spree_role?('support_agent')
        errors[:support_agent] << 'does not has support agent role'
      end
    end
end
