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
  end

  private

  def payment_params
    params.require(:payment).permit(:paymentName, :paymentEmail, :paymentDesc, :paymentAmount, :paymentRefNo, :title, :order_date)
  end
end
