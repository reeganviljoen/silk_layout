# frozen_string_literal: true

module SilkLayout
  module CSS
    Declaration = Struct.new(:value, :important)

    Rule = Struct.new(
      :selector,
      :declarations,
      :specificity,
      :order,
      :origin
    )
  end
end
