class Wish < ApplicationRecord

	def self.save_wish(wish,coin,r_hash)
		wish = Wish.new
		wish.wish = wish
		wish.coin = coin
		wish.payment_hash = r_hash
		wish.save!
	end
end