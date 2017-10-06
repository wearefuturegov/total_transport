@javascript
Feature: Booking a journey

  Background:
    Given there is a route with 5 stops
    And that route has a stop called Newmarket at position 1
    And that route has a stop called Haverhill at position 3
    And that route has 1 outward journey in 3 days time
    And that route has 1 return journey in 4 days time
    And I visit /journeys

  Scenario: Booking a return journey
    When I choose a from point of Newmarket
    And I choose a to point of Haverhill
    And I click See available journeys
    And I click on the first journey's request button
    When I choose the first return option
    And I don't add any special requirements
    And I choose a pickup and dropoff point
    And I fill in my details
    Then I should get an SMS with a confirmation code
    When I enter my confirmation code
    Then I should recieve an SMS confirming my booking
    And my booking should be confirmed
    
  Scenario: Booking a single journey
    Given I have chosen a journey
    But I don't choose a return journey
    And I don't add any special requirements
    And I choose a pickup and dropoff point
    And I fill in my details
    And I enter my confirmation code
    Then my booking should be confirmed
    And my booking should be a single journey
    
  Scenario: Booking a journey with multiple passengers
    Given I have chosen a journey with 3 passengers
    And I choose the first return option
    And I don't add any special requirements
    And I choose a pickup and dropoff point
    And I fill in my details
    And I enter my confirmation code
    Then my booking should be confirmed
    And my booking should have 3 passengers
    
  Scenario: Booking a journey with child tickets
    Given I have chosen a journey with 2 passengers
    And I choose the first return option
    And I choose 1 child ticket
    And I choose a pickup and dropoff point
    And I fill in my details
    And I enter my confirmation code
    Then my booking should be confirmed
    And my booking should have 2 passengers
    And my booking should have 1 child ticket
    
  Scenario: When a from point doesn't exist
    Given the placename service has a place called Somewhere
    When I choose a from point of Somewhere
    Then I should see the message
      """
      Sorry, we don't currently travel from Somewhere.
      """
    
  Scenario: When a destination doesn't exist
    Given the placename service has a place called Somewhere
    When I choose a from point of Newmarket
    And I choose a to point of Somewhere
    Then I should see the message
      """
      Sorry, we don't currently travel from Newmarket to Somewhere.
      """
    And I should see a suggestion of a journey from Newmarket to Haverhill
