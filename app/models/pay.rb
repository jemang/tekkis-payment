class Pay < Flexirest::Base
  verbose!

  request_body_type :json

  base_url ENV["TEKKIS_BASE_URL"]

  post :create, "/payment/addPaymentFromExternal"
  post :status, "/payment/getPaymentDetailsExternal"

  after_request :set_header_content_type

  private

  def set_header_content_type(_name, respond)
    respond.headers["Content-Type"] = "application/json"
  end

end
