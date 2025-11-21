module MomGo
  module TenantScoped
    extend ActiveSupport::Concern

    included do
      belongs_to :shop

      validates :shop, presence: true

      scope :for_shop, ->(shop) { unscope(where: :shop_id).where(shop_id: shop.id) }

      default_scope do
        current_shop_id = Current.shop&.id
        current_shop_id ? where(shop_id: current_shop_id) : all
      end
    end

    class_methods do
      def without_tenant_scope(&block)
        block_given? ? unscoped(&block) : unscoped
      end
    end
  end
end
