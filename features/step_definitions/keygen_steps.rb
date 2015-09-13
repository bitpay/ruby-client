@token = nil
@error = nil

When(/^the user pairs with BitPay(?: with a valid pairing code|)$/) do
  @client = new_client_from_stored_values
  claim_code = get_claim_code_from_server @client
  sleep 1 # rate limit compliance
  @token = @client.pair_pos_client(claim_code)
end

Given(/^the user is authenticated with BitPay$/) do
  @client = new_client_from_stored_values
  raise "client not authenticated" unless client_has_tokens(@client)
end

Given(/^the user is paired with BitPay$/) do
  raise "Client is not paired" unless @client.verify_tokens
end

Then(/^the user receives an? ([A-z]+) token from bitpay$/) do |expected|
  actual = @token[0]["policies"][0]["method"]
  raise "Token not correct, #{actual} != #{expected}" unless actual == expected
end

Given(/^the user has a bad pairing_code "(.*?)"$/) do |arg1|
    # This is a no-op, pairing codes are transient and never actually saved
end

Then(/^the user fails to pair with a semantically (?:in|)valid code "(.*?)"$/) do |code|
  pem = BitPay::KeyUtils.generate_pem
  client = BitPay::SDK::Client.new(api_uri: APIURI, pem: pem, insecure: true)
  begin
    sleep 1 # rate limit compliance
    client.pair_pos_client(code)
    raise "pairing unexpectedly worked"
  rescue => error
    @error = error
    true
  end
end

Then(/^they will receive an? (.*?) matching "(.*?)"$/) do |error_class, error_message|
  raise "Error: #{@error.class}, message: #{@error.message}" unless Object.const_get(error_class) == @error.class && @error.message.include?(error_message)
end

Given(/^the user performs a client\-side pairing$/) do
  sleep 1
  pem = BitPay::KeyUtils.generate_pem
  @client = BitPay::SDK::Client.new(api_uri: APIURI, pem: pem, insecure: true)
  @token = @client.pair_client({facade: 'merchant'})
end

Then(/^the user has a merchant token$/) do
  tokens = {'merchant' => @token}
  raise "Merchant token not authorized" unless @client.verify_tokens(tokens: tokens)
end
