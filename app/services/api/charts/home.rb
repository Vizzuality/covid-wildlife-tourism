module Api
  module Charts
    class Home
      def users_per_day
        ::User.where(role: :user).group_by_day(:created_at).count
      end
    end
  end
end
