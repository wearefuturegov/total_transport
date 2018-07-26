@javascript @que
Feature: Cancelling a booking
  
  Background:
    Given I have made a booking
    
  Scenario: Reason is recorded
    When I cancel my booking
    Then my booking should be cancelled
    And I should see that my booking has been cancelled
    And my cancellation reason should be recorded
  
  Scenario: Alerts sent and cancelled
    When I cancel my booking
    Then my alerts should be cancelled
    And I should receive a cancellation email
  
  Scenario: Refund should be applied
    Given I have paid by card
    Then my payment should be refunded
    When I cancel my booking
    
