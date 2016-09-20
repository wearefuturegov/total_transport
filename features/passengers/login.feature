Feature: Logging in
  Scenario: Successful login for new user
    When I go to the home page
    And I fill in "Enter your mobile number to get started." with "+14108675309" within the login form
    And I press "Verify My Number" within the login form
    And I submit the correct verification code
    Then I should see "Choose Your Route"
