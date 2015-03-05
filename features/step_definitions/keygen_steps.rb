@token = nil
@error = nil

When(/^the user pairs with BitPay(?: with a valid pairing code|)$/) do
  claim_code = get_claim_code_from_server
  pem = BitPay::KeyUtils.generate_pem
  @client = BitPay::SDK::Client.new(api_uri: ROOT_ADDRESS, pem: pem, insecure: true)
  sleep 1 # rate limit compliance
  @token = @client.pair_pos_client(claim_code)
end

When(/^the fails to pair with BitPay because of an incorrect port$/) do
  pem = BitPay::KeyUtils.generate_pem
  address = ROOT_ADDRESS.split(':').slice(0,2).join(':') + ":999"
  client = BitPay::SDK::Client.new(api_uri: address, pem: pem, insecure: true)
  begin
    sleep 1 # rate limit compliance
    client.pair_pos_client("1ab2c34")
    raise "pairing unexpectedly worked"
  rescue => error
    @error = error
    true
  end
end

Given(/^the user is authenticated with BitPay$/) do
  @client = new_client_from_stored_values
end

Given(/^the user is paired with BitPay$/) do
  raise "Client is not paired" unless @client.verify_tokens
end

Given(/^the user has a bad pairing_code "(.*?)"$/) do |arg1|
    # This is a no-op, pairing codes are transient and never actually saved
end

Then(/^the user fails to pair with a semantically (?:in|)valid code "(.*?)"$/) do |code|
  pem = BitPay::KeyUtils.generate_pem
  client = BitPay::SDK::Client.new(api_uri: ROOT_ADDRESS, pem: pem, insecure: true)
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
  @client = BitPay::SDK::Client.new(api_uri: ROOT_ADDRESS, pem: pem, insecure: true)
  response = @client.pair_client({facade: 'merchant'})
  @token = response.first["token"]
  approve_token_on_server(response.first["pairingCode"])
end

Then(/^the user has a merchant token$/) do
  tokens = {'merchant' => @token}
  raise "Merchant token not authorized" unless @client.verify_tokens(tokens: tokens)
end
