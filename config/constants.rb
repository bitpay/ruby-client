## Verifies test variables have been set correctly 
#
#  Use 'set_constants.sh' to pre-configure test variables
#  e.g.
#    source ./spec/set_constants.sh https://test.bitpay.com testuser@gmail.com mypassword
#

APIURI = ENV['BITPAYAPI']

# Specify a bitpay txid which has 6+ confirmations.  Default belongs to 'bitpayrubyclient@gmail.com' test account
REFUND_TRANSACTION = ENV['REFUND_TRANSACTION']
REFUND_ADDRESS = ENV['REFUND_ADDRESS']
