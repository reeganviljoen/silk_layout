# frozen_string_literal: true

module SilkLayout
  module CSS
    Rule = Struct.new(
      :selector,
      :declarations,
      :specificity,
      :order,
      keyword_init: true
    )
  end
end
