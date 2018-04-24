class WishesController < ApplicationController
	def create_invoice
	  invoice = LndInterface.generate_invoice(params[:wish], params[:coin])
	  payment_request = invoice.payment_request
	  #translate any binary data into purely printable characters
	  session[:r_hash] = Base64.encode64(invoice.r_hash)
	  session[:wish] = params[:wish]
	  session[:coin] = params[:coin]
	  ip = LndInterface.get_machine_ip
	  lnd_pub_key = LndInterface.get_lnd_info.identity_pubkey
	  peer_node = lnd_pub_key + "@" + ip + ":9735"
	  render :json => {"payment_request" => payment_request, "peer" => peer_node}
	end

	def convert_coin_to_bitcoins
		render :json => {"bitcoins" => LndInterface.convert_coin_to_satoshi(params[:coin]).to_s}
	end

	def check_payment
	  r_hash = Base64.decode64(session[:r_hash])
	  session[:wish] = params[:wish]
	  settled = LndInterface.check_payment(r_hash)
	  render :json => {"settled" => settled}
	end

	def get_count
	  count = Wish.count
	  render :json => {"count" => count}
	end

	def save_wish
	  Wish.save_wish(session[:wish], session[:coin], session[:r_hash])
	  render :json => {"success" => true}
	end

	def update_email
		wish = Wish.find_by_payment_hash(session[:r_hash])
		wish.email = params[:email]
		wish.save!
		render :json => {"success" => true}
	end
end