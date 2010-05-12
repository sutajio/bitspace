class PaymentsController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  
  layout 'site'
  
  skip_before_filter :require_user
  skip_before_filter :verify_authenticity_token, :only => [:paypal_ipn, :paypal_ipn_label]
  skip_before_filter :require_chrome_frame_if_ie
  
  def paypal_ipn
    notify = Paypal::Notification.new(request.raw_post)
    
    if notify.acknowledge && params[:receiver_email] == ENV['PAYPAL_USERNAME']
      case notify.type
      when 'subscr_signup':
        user = User.find_by_email(Iconv.conv('utf-8', params[:charset], params[:payer_email]))
        if user
          user.upgrade_subscription_plan!(
            :subscription_id => params[:subscr_id],
            :subscription_plan => params[:item_name],
            :first_name => Iconv.conv('utf-8', params[:charset], params[:first_name]),
            :last_name => Iconv.conv('utf-8', params[:charset], params[:last_name]))
        else
          Invitation.create!(
            :email => Iconv.conv('utf-8', params[:charset], params[:payer_email]),
            :subscription_id => params[:subscr_id],
            :subscription_plan => params[:item_name],
            :first_name => Iconv.conv('utf-8', params[:charset], params[:first_name]),
            :last_name => Iconv.conv('utf-8', params[:charset], params[:last_name]))
        end
      when 'subscr_payment':
        # Send reciept?
      when 'subscr_failed':
        user = User.find_by_subscription_id(params[:subscr_id])
        user.handle_failed_payment! if user
      when 'subscr_cancel':
        user = User.find_by_subscription_id(params[:subscr_id])
        user.cancel_subscription! if user
      when 'subscr_eot':
        # Subscription expired (should never happen)
      when 'subscr_modify':
        user = User.find_by_subscription_id(params[:subscr_id])
        user.upgrade_subscription_plan!(
          :subscription_id => params[:subscr_id],
          :subscription_plan => params[:item_name],
          :first_name => Iconv.conv('utf-8', params[:charset], params[:first_name]),
          :last_name => Iconv.conv('utf-8', params[:charset], params[:last_name])) if user
      end
    end
    
    head :ok
  end
  
  def paypal_ipn_label
    notify = Paypal::Notification.new(request.raw_post)
    
    if notify.acknowledge
      case notify.type
      when 'subscr_signup':
        @label = User.find(params[:item_number])
        @user = User.find(params[:custom])
        if params[:mc_amount3] == @label.subscription_price &&
           params[:mc_currency] == @label.subscription_currency
          Subscription.create!(
            :user => @label,
            :subscriber => @user,
            :subscription_id => params[:subscr_id])
        else
          raise "Invalid amount and currency."
        end
      when 'subscr_eot':
        @subscription = Subscription.find_by_subscription_id(params[:subscr_id])
        @subscription.destroy if @subscription
      end
    end
    
    head :ok
  end
  
  def success
  end
  
  def upgraded
  end
  
  def cancel
  end
  
end
