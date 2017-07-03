Feature: Logging in
  @vcr
  Scenario: Successful login for new user
    When I go to the home page
    And I fill in "Get started with your mobile number" with "+447811407085" within the login form
    And I press "Verify Number" within the login form
    And I submit the correct verification code
    Then I should see "Choose Your Route"

  @vcr
  Scenario: Login attempt with invalid phone number format
    When I go to the home page
    And I fill in "Get started with your mobile number" with "239" within the login form
    And I press "Verify Number" within the login form
    Then I should see "Phone number is not a valid, please try another one"

  Scenario: Login attempt with no phone number
    When I go to the home page
    And I fill in "Get started with your mobile number" with "" within the login form
    And I press "Verify Number" within the login form
    Then I should see "Phone number is not a valid, please try another one"

  @vcr
  Scenario: Login attempt with invalid verification code
    When I go to the home page
    And I fill in "Get started with your mobile number" with "+447811407085" within the login form
    And I press "Verify Number" within the login form
    And I submit an incorrect verification code
    Then I should see "That verification code was incorrect"
