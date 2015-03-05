## Verifies test variables have been set correctly 
#
#  Use 'set_constants.sh' to pre-configure test variables
#  e.g.
#    source ./spec/set_constants.sh https://test.bitpay.com testuser@gmail.com mypassword
#

ROOT_ADDRESS = ENV['RCROOTADDRESS']
TEST_USER = ENV['RCTESTUSER']
TEST_PASS = ENV['RCTESTPASSWORD']
DASHBOARD_URL = "#{ROOT_ADDRESS}/dashboard/merchant/home"

# Specify a bitpay txid which has 6+ confirmations.  Default belongs to 'bitpayrubyclient@gmail.com' test account
REFUND_TRANSACTION = ENV['REFUND_TRANSACTION']
REFUND_ADDRESS = ENV['REFUND_ADDRESS']

unless
  ROOT_ADDRESS &&
  TEST_USER &&
  TEST_PASS
then
  raise "Missing configuration options - see constants.rb"
end
