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
    And I click the book journey button
    And I choose a journey
    And I choose a pickup and dropoff point
    And I fill in my details
    And I confirm my booking
    Then I should recieve an SMS confirming my booking
    And my booking should be confirmed
    
  Scenario: Booking a single journey
    Given I have chosen a single journey
    But I don't choose a return journey
    And I fill in my details
    And I confirm my booking
    Then my booking should be confirmed
    And my booking should be a single journey
    
  Scenario: Booking a journey with multiple passengers
    Given I have chosen a journey
    And I choose 3 adult passengers
    And I fill in my details
    And I confirm my booking
    Then my booking should be confirmed
    And my booking should have 3 passengers
    
  Scenario: Booking a journey with child tickets
    Given I have chosen a journey
    And I choose 1 adult passenger
    And I choose 1 child passenger
    And I fill in my details
    And I confirm my booking
    Then my booking should be confirmed
    And my booking should have 2 passengers
    And my booking should have 1 child ticket
      
  @que
  Scenario: When a from point doesn't exist
    Given there is a place with no routes called Somewhere
    When I choose a from point of Somewhere
    Then I should see the message
      """
      We don't currently travel from Somewhere.
      """
    And the origin Somewhere should be logged
  
  @que
  Scenario: When a destination doesn't exist
    Given there is a place with no routes called Somewhere
    When I choose a from point of Newmarket
    And I choose a to point of Somewhere
    Then I should see the message
      """
      We don't currently travel to Somewhere.
      """
    And I should see a suggestion of a journey from Newmarket to Haverhill
    And the origin Newmarket should be logged
    And the destination Somewhere should be logged
