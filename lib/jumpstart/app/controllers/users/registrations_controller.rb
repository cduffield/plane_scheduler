class Users::RegistrationsController < Devise::RegistrationsController
  invisible_captcha only: :create
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_user_registration_path, alert: I18n.t("try_again_later") }

  def create
    if existing_invited_user?
      store_location_for(:user, account_invitation_path(@account_invitation))
      redirect_to new_user_session_path, alert: t("account_invitations.account_exists", email: @account_invitation.email)
    else
      super
    end
  end

  protected

  def build_resource(hash = {})
    self.resource = resource_class.new_with_session(hash, session)

    # Registering to accept an invitation should display the invitation on sign up
    if params[:invite] && (invite = AccountInvitation.find_by(token: params[:invite]))
      @account_invitation = invite

      # Use name/email from the invite if not already provided. Email defaults to "" so it must use a presence check.
      resource.name ||= invite.name
      resource.email = resource.email.presence || invite.email

    # Build and display account fields in registration form if needed
    elsif Jumpstart.config.register_with_account?
      resource.owned_accounts.first || resource.owned_accounts.new
    end
  end

  def update_resource(resource, params)
    # Jumpstart: Allow user to edit their profile without password
    resource.update_without_password(params)
  end

  def configure_permitted_parameters
    super

    devise_parameter_sanitizer.permit(:account_update, keys: profile_update_keys)
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def sign_up(resource_name, resource)
    super

    refer(resource) if defined? Refer

    if @account_invitation
      # Remove any default team accounts to make the invited account the default.
      current_user.accounts.where(personal: false).destroy_all
      @account_invitation.accept!(current_user)

      # Clear redirect to account invitation since it's already been accepted
      stored_location_for(:user)
    end
  end

  private

  def existing_invited_user?
    return false unless params[:invite]

    @account_invitation = AccountInvitation.find_by(token: params[:invite])
    return false unless @account_invitation

    User.exists?(["LOWER(email) = ?", @account_invitation.email.to_s.downcase])
  end

  def profile_update_keys
    [
      :avatar,
      :name,
      :first_name,
      :last_name,
      :phone,
      :preferred_language,
      :theme,
      :total_time,
      :pic_time,
      :sic_time,
      :cross_country_time,
      :instrument_time,
      :night_time,
      :simulator_time,
      :dual_received_time,
      :solo_time,
      pilot_certificates: [],
      aircraft_categories: [],
      aircraft_classes: [],
      user_pilot_certificates_attributes: [
        :id,
        :certificate_type,
        :category,
        :aircraft_class,
        :certificate_number,
        :issued_on,
        :_destroy
      ],
      user_medical_certificate_attributes: [
        :id,
        :medical_class,
        :certificate_number,
        :issued_on,
        :expires_on
      ]
    ]
  end
end
