@javascript
Feature: Booking a journey with concessions

  Background:
    Given there is a route with 5 stops
    And that route has a stop called Newmarket at position 1
    And that route has a stop called Haverhill at position 3
    And that route has 1 outward journey in 3 days time
    And that route has 1 return journey in 3 days time
    And I visit /journeys

  Scenario: Older Persons Bus Pass
    Given I have chosen a journey
    And I choose 3 adult passengers
    And I choose 2 "older people's" bus passes
    And I fill in my details
    And I confirm my booking
    Then my booking should be confirmed
    And my booking should have 3 passengers
    And my booking should have 2 "older people's" bus passes
    
  Scenario: Disabled Bus Pass
    Given I have chosen a journey
    And I choose 2 adult passengers
    And I choose 1 "disabled" bus pass
    And I fill in my details
    And I confirm my booking
    Then my booking should be confirmed
    And my booking should have 2 passengers
    And my booking should have 1 "disabled" bus pass
