@javascript
Feature: Choosing a journey

  Background:
    Given there is a route with 5 stops
    And that route has a stop called Newmarket at position 1
    And that route has a stop called Haverhill at position 3
    And the route has an outward journey at 8am in 3 days time
    And the route has a return journey at 3pm in 3 days time
    And I visit /journeys

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
      Unfortunately, we don't currently travel to Somewhere.
      """
    And I should see a suggestion of a journey from Newmarket to Haverhill
    And the origin Newmarket should be logged
    And the destination Somewhere should be logged
