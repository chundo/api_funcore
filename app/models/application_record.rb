class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  self.abstract_class = true

  connects_to database: { writing: :primary }

  def self.generate_code(a, b)
    code_randon = [('A'..'Z'), (0..9)].map(&:to_a).flatten
    (a...b).map { code_randon[rand(code_randon.length)] }.join
  end
end
