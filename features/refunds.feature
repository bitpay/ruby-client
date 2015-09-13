@refunds
Feature: issuing a refund
  The merchant wants to issue a refund
  So that they can serve their customers

  Background:
    Given the user is authenticated with BitPay

  Scenario: creating a refund
    Given the user creates a refund
    Then they will receive a refund id
  
  Scenario: retrieving a refund
    Given the user requests a specific refund
    Then they will receive the refund 
    
  Scenario: retrieving all refunds
    Given the user requests all refunds for an invoice
    Then they will receive an array of refunds

  Scenario: canceling a refund
    Given a properly formatted cancellation request
    Then the refund will be cancelled
