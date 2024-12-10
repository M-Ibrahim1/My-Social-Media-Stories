# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  respond_to :json

  # POST /users/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      return my_success_response(message: "Instructions for resetting the password have been sent successfully!")
    else
      return my_failure_response(message: "Reset password instructions not sent!", errors: resource.errors.full_messages)
    end
  end

  # PUT /users/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      return my_success_response(message: "Password reset successful!")
    else
      return my_failure_response(message: "Password reset unsuccessful!", errors: resource.errors.full_messages)
    end
  end

  private

  def resource_params
    params.require(:user).permit(:email, :reset_password_token, :password, :password_confirmation)
  end
end
