@javascript @
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
    Then my booking should be confirmed
    And my booking should have a charge id
    And my payment method should be card
