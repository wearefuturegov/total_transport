Feature: Booking a journey

  @javascript
  Scenario: Successful booking with no existing payment methods
    Given I am logged in
    And the Sudbury to Saffron Walden route exists
    And the route has a journey at 6pm tomorrow
    When I go to the home page
    And I follow "Customise This Route" for the route
    And I click "Haverhill"
    And I click "Halstead"
    And I press "View Times"
    And I press "Define Pick Up Point"
    And I press "Confirm Pick Up Point"
    And I press "Confirm Drop Off Point"
    Then I should not see "Add a payment method"
    When I click "Credit card"
    Then I should see "17:57 - 18:17 Haverhill"
    And I should see "18:01 - 18:21 Halstead"
    And I should see "Paying with Credit card"

  @javascript
  Scenario: Successful booking with existing payment method
    Given I am logged in
    And I have an existing credit card payment method
    And the Sudbury to Saffron Walden route exists
    And the route has a journey at 6pm tomorrow
    When I go to the home page
    And I follow "Customise This Route" for the route
    And I click "Haverhill"
    And I click "Halstead"
    And I press "View Times"
    And I press "Define Pick Up Point"
    And I press "Confirm Pick Up Point"
    And I press "Confirm Drop Off Point"
    Then I should see "Add a payment method"
    When I click "Credit card"
    Then I should see "17:57 - 18:17 Haverhill"
    And I should see "18:01 - 18:21 Halstead"
    And I should see "Paying with Credit card"

  @javascript
  Scenario: Successful booking with existing payment method
    Given I am logged in
    And I have an existing credit card payment method
    And the Sudbury to Saffron Walden route exists
    And the route has a journey at 6pm tomorrow
    When I go to the home page
    And I follow "Customise This Route" for the route
    And I click "Haverhill"
    And I click "Halstead"
    And I press "View Times"
    And I press "Define Pick Up Point"
    And I press "Confirm Pick Up Point"
    And I press "Confirm Drop Off Point"
    And I click "Add a payment method"
    And I click "Paypal"
    Then I should see "17:57 - 18:17 Haverhill"
    And I should see "18:01 - 18:21 Halstead"
    And I should see "Paying with Paypal"
