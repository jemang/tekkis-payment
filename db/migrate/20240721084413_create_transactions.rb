class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.json :request_payload
      t.json :respond_payload
      t.json :webhook_respond
      t.integer :payment_status, default: 0
      t.string :payment_link
      t.string :payment_uuid
      t.string :payment_invoice_no
      t.string :payment_unique_key
      t.datetime :payment_cleared_at

      t.timestamps
    end
  end
end
