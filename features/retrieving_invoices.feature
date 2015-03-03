Feature: retrieving an invoice
  The user may want to retrieve invoices
  So that they can view them

  Scenario: Correct public request
    Given that a user knows an invoice id
    Then they can retrieve the public version of that invoice

  Scenario: Correct merchant request
    Given that a user knows an invoice id
    Then they can retrieve the merchant-scoped version of that invoice    
