class Wish < ApplicationRecord

	def self.save_wish(wish_text,coin,r_hash)
		wish = Wish.new
		wish.wish = wish_text
		wish.coin = coin
		wish.payment_hash = r_hash
		wish.save!
	end
end