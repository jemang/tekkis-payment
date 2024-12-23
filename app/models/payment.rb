class Payment
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :redirect_url, :respond

  attribute :paymentName, :string, default: -> { Faker::Name.name_with_middle }
  attribute :paymentEmail, :string, default: -> { Faker::Internet.email }
  attribute :paymentDesc, :string, default: -> { Faker::Food.description }
  attribute :paymentAmount, :string, default: 20.00
  attribute :paymentRefNo, :string, default: -> { Time.zone.now.strftime("ABC%Y%m%d%H%M%S") }
  attribute :title, :string, default: "Food"
  attribute :order_date, :datetime, default: -> { Time.zone.now }

  def create_order
    @response = TekkisPay.create(payload_data)

    # create transaction record ##
    transaction = Transaction.create(
      payment_uuid: paymentRefNo,
      request_payload: payload_data
    )

    if @response._status == 200
      Rails.logger.info @response
      puts @response
      paymentDetails = @response.response.paymentDetails
      transaction.update(
        respond_payload: paymentDetails.as_json,
        payment_link: paymentDetails.payment_link,
        payment_unique_key: paymentDetails.payment_unique_key,
        payment_invoice_no: paymentDetails.payment_ref_no
      )

      self.redirect_url = paymentDetails.payment_link
    end
  rescue Flexirest::HTTPBadRequestClientException, Flexirest::HTTPClientException => e
    errors.add(:base, e.body)
    false
  end

  def status_payment(payment_unique_key)
    params = {
      merchantKey: merchant_key,
      signature: signature,
      paymentUniqueKey: payment_unique_key
    }

    payload = Base64.strict_encode64(params.to_json)

    @response = TekkisPay.status(
      {
        payload: payload
      }
    )
    self.respond = @response.response
  rescue Flexirest::HTTPBadRequestClientException, Flexirest::HTTPClientException => e
    self.respond = e.body
  end

  def merchant_key
    ENV["PAYMENT_MERCHANT_KEY"]
  end

  def signature
    secret = ENV["PAYMENT_SECRET"]
    data = merchant_key + secret
    Digest::SHA256.hexdigest(data)
  end

  def payload_base64
    Base64.encode64(payload_params.to_json).strip
  end

  def self.payload_decode_base64(data)
    decode = Base64.decode64(data)
    JSON.parse(decode)
  end

  def payload_data
    {
      payload: payload_base64
    }
  end

  def payload_params
    {
      merchantKey: merchant_key,
      signature: signature,
      paymentName: paymentName,
      paymentEmail: paymentEmail,
      paymentDesc: paymentDesc,
      paymentAmount: paymentAmount,
      paymentRefNo: paymentRefNo,
      paymentRedirectURL: ENV["PAYMENT_REDIRECT_URL"],
      paymentCallbackURL: ENV["PAYMENT_CALLBACK_URL"],
      paymentCustomFields: [
        {
          title: title,
          value: order_date.strftime("%Y-%m-%d %H:%M:%S")
        }
      ]
    }
  end
end
