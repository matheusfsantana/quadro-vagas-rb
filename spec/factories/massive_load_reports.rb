FactoryBot.define do
  factory :massive_load_report do
    massive_load_input { nil }
    type { 1 }
    status { 1 }
    row_number { 1 }
    description { "MyString" }
  end
end
