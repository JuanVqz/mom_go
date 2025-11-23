module CartSupport
  extend ActiveSupport::Concern

  private

  def current_cart
    @current_cart ||= OrderCart.new(session:, shop: Current.shop)
  end
end
