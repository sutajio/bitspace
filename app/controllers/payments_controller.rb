class PaymentsController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  
  skip_before_filter :require_user
  skip_before_filter :verify_authenticity_token, :only => [:paypal_ipn]
  
  def paypal_ipn
    notify = Paypal::Notification.new(request.raw_post)
    
    if notify.acknowledge && params[:receiver_email] == 'paypal@bitspace.se'
      case notify.type
      when 'subscr_signup':
        user = User.find_or_create_by_email(
          :email => params[:payer_email],
          :subscription_id => params[:subscr_id],
          :subscription_plan => params[:item_name],
          :name => [params[:first_name], params[:last_name]].join(' '))
        user.save!
        Invitation.create(:email => user.email)
      when 'subscr_payment':
        # Send reciept?
      when 'subscr_failed':
        user = User.find_by_subscription_id(params[:subscr_id])
        user.handle_failed_payment
      when 'subscr_cancelled':
        user = User.find_by_subscription_id(params[:subscr_id])
        user.cancel_subscription
      end
    end
    
    head :ok
  end
  
  def success
  end
  
  def cancel
  end
  
end
