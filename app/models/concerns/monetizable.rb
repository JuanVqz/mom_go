require "bigdecimal"

module Monetizable
  extend ActiveSupport::Concern

  class_methods do
    def monetizes(*fields, currency_attribute: nil)
      fields.each do |field|
        method_name = field.to_s.sub(/_cents\z/, "")

        define_method(method_name) do
          cents = public_send(field)
          cents.nil? ? nil : BigDecimal(cents.to_s) / 100
        end

        define_method("formatted_#{method_name}") do
          amount = public_send(method_name) || BigDecimal("0")
          currency_code =
            if currency_attribute
              public_send(currency_attribute)
            elsif respond_to?(:currency)
              currency
            else
              "MXN"
            end

          Monetizable.format_currency(amount, currency_code)
        end
      end
    end
  end

  def self.format_currency(amount, currency_code)
    return "" if amount.nil?

    decimal = amount.is_a?(BigDecimal) ? amount : BigDecimal(amount.to_s)
    sign = decimal.negative? ? "-" : ""
    absolute = decimal.abs
    "#{sign}$#{format('%.2f', absolute)} #{currency_code.presence || 'MXN'}"
  end
end
