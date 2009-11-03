class PaymentsController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  
  skip_before_filter :require_user
  
  signup = {
    "btn_id"=>"9369035",
    "business"=>"paypal@bitspace.se",
    "charset"=>"windows-1252",
    "first_name"=>"Niklas",
    "item_name"=>"Bitspace Premium",
    "last_name"=>"Holmgren",
    "mc_amount1"=>"0.00",
    "mc_amount3"=>"7.99",
    "mc_currency"=>"EUR",
    "notify_version"=>"2.8",
    "payer_email"=>"niklas.holmgren@gmail.com",
    "payer_id"=>"VUNHTRUFSC2Q4",
    "payer_status"=>"unverified",
    "period1"=>"1 M",
    "period3"=>"1 M",
    "reattempt"=>"1",
    "receiver_email"=>"paypal@bitspace.se",
    "recurring"=>"1",
    "residence_country"=>"SE",
    "subscr_date"=>"08:11:23 Nov 02, 2009 PST",
    "subscr_id"=>"I-D2SG0P1K3FTS",
    "txn_type"=>"subscr_signup",
    "verify_sign"=>"AsOuxs67kWCsUADH5pUULt.GZzcpAxJ5lBp4eejIV-q2uP-6nfPT4PQB",
  }
  
  suspend = {
    "btn_id"=>"9369035",
    "business"=>"paypal@bitspace.se",
    "charset"=>"windows-1252",
    "first_name"=>"Niklas",
    "item_name"=>"Bitspace Premium",
    "last_name"=>"Holmgren",
    "mc_amount1"=>"0.00",
    "mc_amount3"=>"7.99",
    "mc_currency"=>"EUR",
    "notify_version"=>"2.8",
    "payer_email"=>"niklas.holmgren@gmail.com",
    "payer_id"=>"VUNHTRUFSC2Q4",
    "payer_status"=>"unverified",
    "period1"=>"1 M",
    "period3"=>"1 M",
    "reattempt"=>"1",
    "receiver_email"=>"paypal@bitspace.se",
    "recurring"=>"1",
    "residence_country"=>"SE",
    "subscr_date"=>"08:11:23 Nov 02, 2009 PST",
    "subscr_id"=>"I-D2SG0P1K3FTS",
    "txn_type"=>"subscr_signup",
    "verify_sign"=>"AsOuxs67kWCsUADH5pUULt.GZzcpAxJ5lBp4eejIV-q2uP-6nfPT4PQB",
  }
  
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
    
    render :nothing
  end
  
  def success
  end
  
  def cancel
  end
  
end
