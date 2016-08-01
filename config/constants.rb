## Verifies test variables have been set correctly 
#
#  Use 'set_constants.sh' to pre-configure test variables
#  e.g.
#    source ./spec/set_constants.sh https://test.bitpay.com testuser@gmail.com mypassword
#

APIURI = ENV['BITPAYAPI']
PEM = ENV['BITPAYPEM'] || "-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEICg7E4NN53YkaWuAwpoqjfAofjzKI7Jq1f532dX+0O6QoAcGBSuBBAAK\noUQDQgAEjZcNa6Kdz6GQwXcUD9iJ+t1tJZCx7hpqBuJV2/IrQBfue8jh8H7Q/4vX\nfAArmNMaGotTpjdnymWlMfszzXJhlw==\n-----END EC PRIVATE KEY-----\n"

# Specify a bitpay txid which has 6+ confirmations.  Default belongs to 'bitpayrubyclient@gmail.com' test account
REFUND_TRANSACTION = ENV['REFUND_TRANSACTION']
REFUND_ADDRESS = ENV['REFUND_ADDRESS']
