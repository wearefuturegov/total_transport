@javascript
Feature: Booking a journey with concessions

  Background:
    Given there is a route with 5 stops
    And that route has a stop called Newmarket at position 1
    And that route has a stop called Haverhill at position 3
    And the route has an outward journey at 8am in 3 days time
    And the route has a return journey at 3pm in 3 days time
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
    
  Scenario: Removing a pass
    Given I have chosen a journey
    And I choose 2 adult passengers
    And I choose 1 "disabled" bus pass
    And I remove the bus pass
    Then I should see the price for 2 adult passengers

  Scenario: Adding more passes than passengers
    Given I have chosen a journey
    And I choose 2 adult passengers
    And I choose 3 "disabled" bus passes
    Then I should see "The number of passes must not exceed the number of passengers"

  Scenario: Adding extra passes
    Given I have chosen a journey
    And I choose 2 adult passengers
    And I choose 1 "disabled" bus pass
    And I choose 3 "older people's" bus passes
    Then I should see "The number of passes must not exceed the number of passengers"
    
  Scenario: Pass type can only be added once
    Given I have chosen a journey
    And I choose 2 adult passengers
    And I choose 1 "disabled" bus pass
    Then I should not be able to choose another "disabled" bus pass
    
  Scenario: When allow concessions is set to false
    Given the route has allow concessions set to false
    And I have chosen a journey
    Then I should not see the concessions selector
