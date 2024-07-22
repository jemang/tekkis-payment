class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(payment_params)
    if @payment.create_order
      redirect_to(@payment.redirect_url, allow_other_host: true)
    else
      render :new
    end
  end

  def show
    @payment = Payment.new
    @payment.status_payment(params[:id])
    respond_with(@payment)
  end

  def callback
    Rails.logger.info "masuk callback"
    Rails.logger.debug params
  end

  def webhook
    Rails.logger.info "masuk webhook"
    Rails.logger.debug params
    if params["payload"].present?
      payload = Payment.payload_decode_base64(params["payload"])
      transaction = Transaction.find_by(payment_unique_key: payload["payment_unique_key"])
      if transaction.present? && !transaction.completed?
        cleared_date = payload["payment_status"] == "completed" ? Time.zone.now : nil
        transaction.update(payment_status: payload["payment_status"], payment_cleared_at: cleared_date, webhook_respond: params["payload"])
      end
    end
    render :nothing => true
  end

  private

  def payment_params
    params.require(:payment).permit(:paymentName, :paymentEmail, :paymentDesc, :paymentAmount, :paymentRefNo, :title, :order_date)
  end
end
