FactoryBot.define do
  factory :item do
    name { "Item #{Faker::Lorem.sentence(word_count: 2)}" }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    unit_price { Faker::Number.between(from: 1.0, to: 1000.0).ceil(2) }
  end
end
