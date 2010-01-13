class PaymentsController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  
  skip_before_filter :require_user
  skip_before_filter :verify_authenticity_token, :only => [:paypal_ipn]
  skip_before_filter :require_chrome_frame_if_ie
  
  def paypal_ipn
    notify = Paypal::Notification.new(request.raw_post)
    
    if notify.acknowledge && params[:receiver_email] == 'paypal@bitspace.se'
      case notify.type
      when 'subscr_signup':
        Invitation.create(
          :email => params[:payer_email],
          :subscription_id => params[:subscr_id],
          :subscription_plan => params[:item_name],
          :first_name => params[:first_name],
          :last_name => params[:last_name])
      when 'subscr_payment':
        # Send reciept?
      when 'subscr_failed':
        user = User.find_by_subscription_id(params[:subscr_id])
        user.handle_failed_payment
      when 'subscr_cancel':
        user = User.find_by_subscription_id(params[:subscr_id])
        user.cancel_subscription
      when 'subscr_eot':
        # Subscription expired (should never happen)
      when 'subscr_modify':
        # Subscription modified
      end
    end
    
    head :ok
  end
  
  def success
  end
  
  def cancel
  end
  
end
