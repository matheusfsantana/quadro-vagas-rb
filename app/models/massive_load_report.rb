class MassiveLoadReport < ApplicationRecord
  belongs_to :massive_load_input

  enum :record_type, { user: 0, company: 1, job: 2, other: 3 }
  enum :status, { fail: 0, success: 1 }

  validates :row_number, presence: true

  after_create_commit do
    broadcast_replace_to "report_count_#{massive_load_input_id}",
      target: "report_#{massive_load_input_id}",
      partial: "massive_load_inputs/report_count",
      locals: { massive_load_input: massive_load_input }
  end
end
