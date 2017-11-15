@javascript @stripe
Feature: Paying online
  
  Background:
    Given there is a route with 5 stops
    And that route has a stop called Newmarket at position 1
    And that route has a stop called Haverhill at position 3
    And that route has 1 outward journey in 3 days time
    And that route has 1 return journey in 3 days time
    And I visit /journeys
    
  Scenario: Successful online payment
    Given I have entered my booking details
    And I pay via online payments
    Then I should see the confirmation page
    And my booking should be confirmed
    And my booking should have a charge id
    And my payment method should be card
    
  Scenario: Unsuccessful online payment
    Given I have an invalid card
    And I have entered my booking details
    And I pay via online payments
    Then I should see an error saying my card has been declined
    And my booking should not be confirmed
