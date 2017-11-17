@javascript
Feature: Booking a journey

  Background:
    Given there is a route with 5 stops
    And that route has a stop called Newmarket at position 1
    And that route has a stop called Haverhill at position 3
    And the route has an outward journey at 8am in 3 days time
    And the route has a return journey at 3pm in 3 days time
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
    And both journeys should show as booked
    
  Scenario: Should not see return journeys before the outward journey
    Given the route has an outward journey at 9am in 3 days time
    And the route has an return journey at 8am in 3 days time
    And I choose the outward journey
    Then I should not see the return journey
    
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
