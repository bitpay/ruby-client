Feature: pairing with bitpay
  In order to access bitpay
  It is required that the library
  Is able to pair successfully

  Scenario: the client has a correct pairing code
    Given the user pairs with BitPay with a valid pairing code
    Then the user receives a require token from bitpay

  Scenario: the client initiates pairing
    Given the user performs a client-side pairing
    Then the user receives an inactive token from bitpay

  Scenario Outline: the client has a bad pairing code
    Given the user fails to pair with a semantically <valid> code <code>
    Then they will receive a <error> matching <message>
  Examples:
      | valid   | code       | error                 | message                       |
      | invalid | "a1b2c3d4" | BitPay::ArgumentError | "pairing code is not legal"   |
