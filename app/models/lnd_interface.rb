class LndInterface < ApplicationRecord

	require 'grpc'
	require 'net/http'
	require 'socket'
	require 'resolv-replace'
	require_relative '../rpc_pb'
	require_relative '../rpc_services_pb'

	US_COIN_TO_DOLLARS = {
		"cent" => 0.01,
		"nickel" => 0.05,
		"dime" => 0.10,
		"quarter" => 0.25,
		"fiftycent" => 0.50,
		"dollar" => 1.0
	}

	ENV["bitcoin_price_api"] = "https://api.coinmarketcap.com/v1/ticker/bitcoin/"
	ENV["GRPC_SSL_CIPHER_SUITES"] = "HIGH+ECDSA"
	
	def self.convert_coin_to_satoshi(coin)
		if US_COIN_TO_DOLLARS.keys.include? coin
			dollar_value = US_COIN_TO_DOLLARS[coin]
		else 
			raise "Coin not recognized"
		end
		return ((dollar_value/(LndInterface.get_bitcoin_price)) * 100000000).round
	end

	#Todo add 5 minute cache
	def self.get_bitcoin_price
		uri = URI.parse(ENV["bitcoin_price_api"])
		res = Net::HTTP.get_response(uri)
		return JSON.parse(res.body).first["price_usd"].to_f
	end

	def self.get_lnd_info
		#Add tls.cert path to configuration file 
		path = "/Users/karanverma/Library/Application\ Support/Lnd/tls.cert"
		channel_creds = GRPC::Core::ChannelCredentials.new(File.read(path))
		#Add lndrpc host and port to configutation file
		stub = Lnrpc::Lightning::Stub.new("localhost:10001", channel_creds)
		obj = Lnrpc::GetInfoRequest.new
		return stub.get_info(obj)		
	end

	#Todo: Test this returns the correct IP address 
	def self.get_machine_ip
		ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
		return ip.ip_address
	end

	def self.generate_invoice(wish, coin)
		#Add tls.cert path to configuration file 
		path = "/Users/karanverma/Library/Application\ Support/Lnd/tls.cert"
		channel_creds = GRPC::Core::ChannelCredentials.new(File.read(path))
		#Add lndrpc host and port to configutation file
		stub = Lnrpc::Lightning::Stub.new("localhost:10001", channel_creds)
		request = Lnrpc::Invoice.new("memo" => wish, "value" => LndInterface.convert_coin_to_satoshi(coin))
		#expire the invoice in 5 minutes

		return stub.add_invoice(request)
	end

	def self.check_payment(r_hash)
		#Add tls.cert path to configuration file 
		path = "/Users/karanverma/Library/Application\ Support/Lnd/tls.cert"
		ENV["GRPC_SSL_CIPHER_SUITES"] = "HIGH+ECDSA"
		channel_creds = GRPC::Core::ChannelCredentials.new(File.read(path))
		#Add lndrpc host and port to configuration file
		stub = Lnrpc::Lightning::Stub.new("localhost:10001", channel_creds)
		request = Lnrpc::PaymentHash.new("r_hash" => r_hash)
		return stub.lookup_invoice(request).settled
	end
end