json.extract! transaction, :id, :request_payload, :respond_payload, :webhook_respond, :status, :payment_link, :payment_invoice_no, :payment_unique_key, :sale_cleared_at, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
