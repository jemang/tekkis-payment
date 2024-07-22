class Transaction < ApplicationRecord
  enum payment_status: { pending: 0, processing: 1, success: 2, failed: 3 }


end
