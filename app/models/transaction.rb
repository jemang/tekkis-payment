class Transaction < ApplicationRecord
  enum payment_status: { pending: 0, processing: 1, completed: 2, rejected: 3, expired: 4 }


end
