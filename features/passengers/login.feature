Feature: Logging in
  @vcr
  Scenario: Successful login for new user
    When I go to the home page
    And I fill in "Enter your mobile number to get started." with "+447811407085" within the login form
    And I press "Verify My Number" within the login form
    And I submit the correct verification code
    Then I should see "Choose Your Route"

  @vcr
  Scenario: Login attempt with invalid phone number format
    When I go to the home page
    And I fill in "Enter your mobile number to get started." with "239" within the login form
    And I press "Verify My Number" within the login form
    Then I should see "Phone number is not a valid phone number"

  @vcr
  Scenario: Login attempt with invalid verification code
    When I go to the home page
    And I fill in "Enter your mobile number to get started." with "+447811407085" within the login form
    And I press "Verify My Number" within the login form
    And I submit an incorrect verification code
    Then I should see "That verification code was incorrect"
