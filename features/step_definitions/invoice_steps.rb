When(/^the user (?:tries to |)creates? an invoice (?:for|without) "(.*?)" (?:or |and |)"(.*?)"$/) do |price, currency|
  begin
    @response = @client.create_invoice(price: price, currency: currency)
  rescue => error
    @error = error
  end
end

Then(/^they should recieve an invoice in response for "(.*?)" "(.*?)"$/) do |price, currency|
  raise "#{@response['price']} != #{price} or #{@response['currency']} != #{currency}" unless (price == @response['price'].to_s && currency == @response['currency'])
end

Given(/^there is an invalid token$/) do
    pending # express the regexp above with the code you wish you had
end

Given(/^that a user knows an invoice id$/) do
  client = new_paired_client
  @id = (client.create_invoice(price: 100, currency: "USD" ))['id']
end

Then(/^they can retrieve that invoice$/) do
  invoice = BitPay::Client.new(api_uri: ROOT_ADDRESS, insecure: true).get_public_invoice(id: @id)
  raise "That's the wrong invoice" unless invoice['id'] == @id
end

