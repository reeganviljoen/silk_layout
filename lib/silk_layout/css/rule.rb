# frozen_string_literal: true

module SilkLayout
  module CSS
    Declaration = Struct.new(:value, :important, keyword_init: true)

    Rule = Struct.new(
      :selector,
      :declarations,
      :specificity,
      :order,
      :origin,
      keyword_init: true
    )
  end
end
