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

unless
  ROOT_ADDRESS &&
  TEST_USER &&
  TEST_PASS
then
  raise "Missing configuration options - see constants.rb"
end
