Given(/^the user creates a refund$/) do
  sleep(1)
  @response = @client.refund_invoice(id: REFUND_TRANSACTION, params: {amount: 1, currency: 'USD', bitcoinAddress: REFUND_ADDRESS})
end

Then(/^they will receive a refund id$/) do
  @refund_id = @response["id"]
  expect(@refund_id).not_to be_empty
end

Given(/^the user requests a specific refund$/) do
  @response = @client.get_refund(invoice_id: REFUND_TRANSACTION, request_id: @refund_id)
end

Then(/^they will receive the refund$/) do
  expect(@response.first["status"]).not_to be_empty
end

Given(/^the user requests all refunds for an invoice$/) do
  client = new_client_from_stored_values
  @response = client.get_all_refunds_for_invoice(id: REFUND_TRANSACTION)
end

Then(/^they will receive an array of refunds$/) do
  expect(@response).to be_instance_of Array
end

Given(/^a properly formatted cancellation request$/) do
  sleep(1)
  client = new_client_from_stored_values
  @refund_id = client.get_all_refunds_for_invoice(id: REFUND_TRANSACTION).first["id"]
  @response = client.cancel_refund(invoice_id: REFUND_TRANSACTION, request_id: @refund_id)
end

Then(/^the refund will be cancelled$/) do
  expect(@response).to eq("Success")
end
