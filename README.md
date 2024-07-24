# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

Here are detailed test scenarios and steps to automate the validation of the requirements for leave management, including Salesforce automation and integration:

### Test Scenarios

1. **Date in the Past:**
   - **Scenario:** Attempt to set a leave request start date in the past.
   - **Expected Outcome:** System should not allow the leave request and should display an appropriate error message.

2. **Duration Longer Than 3 Weeks:**
   - **Scenario:** Attempt to set the leave duration longer than 3 calendar weeks.
   - **Expected Outcome:** System should not allow the leave request and should display an appropriate error message.

3. **Calculate Duration with Working Days Only:**
   - **Scenario:** Set leave duration including weekends.
   - **Expected Outcome:** System should calculate the duration excluding weekends and display the correct duration in working days.

4. **German Holidays as Non-Working Days:**
   - **Scenario:** Set leave duration that includes German public holidays.
   - **Expected Outcome:** System should exclude German holidays from the duration calculation and display the correct duration in working days.

5. **Employee's Annual Vacation Days:**
   - **Scenario:** Create leave requests that exceed the total of 30 days of vacation in a year.
   - **Expected Outcome:** System should not allow leave requests that exceed 30 days in total for the year and should display an appropriate error message.

6. **Vacation Balance Visualization:**
   - **Scenario:** Display the current balance of vacation days.
   - **Expected Outcome:** System should correctly display the current balance of vacation days for the employee.

7. **Leftover Vacation Days:**
   - **Scenario:** Ensure leftover vacation days cannot be negative.
   - **Expected Outcome:** System should not allow the balance of vacation days to go below 0 and should display an appropriate error message.

8. **Send Leave Request for Approval:**
   - **Scenario:** Send a leave request for approval to the manager.
   - **Expected Outcome:** System should send the leave request for approval and notify the manager.

9. **Approval Process:**
   - **Approved Request:**
     - **Scenario:** Approve the leave request.
     - **Expected Outcome:** 
       - Balance of vacation days is updated.
       - Status set to Approved.
       - Automated email notification sent to user with Verivox logo embedded.
       - Email includes old and new balance, type, start, and end date of leave.
   - **Not Approved Request:**
     - **Scenario:** Reject the leave request.
     - **Expected Outcome:** 
       - Balance of vacation days is not reduced.
       - Status set to Not Approved.
       - Automated email notification sent to user with Verivox logo from an external resource.
       
10. **Approval/Rejection Flow:**
    - **Scenario:** Use a custom screen flow to approve/reject leave requests.
    - **Expected Outcome:** 
      - Flow checks if the current user is the manager of the employee.
      - Displays an error message if not the manager.
      - Displays old balance, new balance, start and end date, duration, employee name, type.
      - Provides buttons for approval and rejection.

11. **Create Application for Leave Component:**
    - **Scenario:** Create a Lightning Component or LWC for leave requests on the Home Page.
    - **Expected Outcome:**
      - Fields from the data model are shown.
      - Type field is a dynamic picklist.
      - Start date, end date, and type are mandatory.
      - Current balance of vacation days is shown.
      - Successful database interaction shows a Toast and clears input fields.
      - Failed database interaction shows a Toast.

12. **REST Webservice for Leave Applications:**
    - **Scenario:** Call a REST Webservice with an employee email address.
    - **Expected Outcome:** System returns all leave applications for the email address for the current financial year.

13. **ERP Integration:**
    - **Scenario:** Ensure the ERP system's vacation day balance is updated when a new leave application is approved.
    - **Expected Outcome:** ERP system reflects the updated balance of vacation days after approval.

### Automation Steps

1. **Unit Tests:**
   - Implement unit tests to validate business logic, such as calculating the leave duration excluding weekends and holidays, and ensuring that leave requests cannot exceed 3 weeks.

2. **Apex Tests:**
   - Write Apex tests to verify the behavior of triggers, classes, and workflows involved in managing leave requests.

3. **UI Tests:**
   - Use Selenium or other UI testing tools to automate tests for the Lightning Component, including form submissions, error messages, and Toast notifications.

4. **Email Tests:**
   - Use tools like EmailUnit to automate testing of email notifications, including verifying content, embedded logos, and correct formatting.

5. **Flow Tests:**
   - Automate testing of the screen flow using Apex and Flow Builder to ensure correct user permissions and display of information.

6. **API Tests:**
   - Use Postman or another API testing tool to automate testing of the REST Webservice, ensuring it returns correct data for given input.

7. **Integration Tests:**
   - Automate tests for the ERP integration to ensure the balance of vacation days is updated correctly in the external system.

### Summary

This approach outlines test scenarios and steps for automating the validation of leave management requirements in Salesforce, ensuring comprehensive coverage of both functional and integration aspects.


### Test Scenarios for `DurationCalculator` Class

When writing test scenarios for the `DurationCalculator` class, we need to ensure that we cover all possible edge cases and regular use cases. Here are the key scenarios to test:

#### 1. Basic Working Days Calculation
- **Scenario**: Calculate working days between two dates that do not include any weekends or German holidays.
- **Expected Result**: The number of working days should be the total days between the start and end dates.

#### 2. Including Weekends
- **Scenario**: Calculate working days between two dates that include weekends.
- **Expected Result**: Weekends should be excluded from the count of working days.

#### 3. Including German Holidays
- **Scenario**: Calculate working days between two dates that include German holidays.
- **Expected Result**: German holidays should be excluded from the count of working days.

#### 4. Including Both Weekends and German Holidays
- **Scenario**: Calculate working days between two dates that include both weekends and German holidays.
- **Expected Result**: Both weekends and German holidays should be excluded from the count of working days.

#### 5. Edge Case: Start Date Equals End Date
- **Scenario**: The start date is the same as the end date, and it is a working day.
- **Expected Result**: The number of working days should be 1 if the date is not a weekend or a German holiday.

#### 6. Edge Case: Start Date Equals End Date and It Is a Weekend
- **Scenario**: The start date is the same as the end date, and it is a weekend.
- **Expected Result**: The number of working days should be 0.

#### 7. Edge Case: Start Date Equals End Date and It Is a German Holiday
- **Scenario**: The start date is the same as the end date, and it is a German holiday.
- **Expected Result**: The number of working days should be 0.

#### 8. Date Range Spanning Over Multiple Months
- **Scenario**: Calculate working days between two dates that span over multiple months.
- **Expected Result**: Working days should be accurately calculated across month boundaries, excluding weekends and German holidays.

#### 9. Entire Date Range is Weekends and/or German Holidays
- **Scenario**: The entire date range consists of weekends and/or German holidays.
- **Expected Result**: The number of working days should be 0.

#### 10. Empty Holiday List
- **Scenario**: There are no German holidays configured.
- **Expected Result**: Only weekends should be excluded from the count of working days.

### Example Test Class

Here is a test class covering the above scenarios:

### Summary

This test class covers a variety of scenarios for the `DurationCalculator` class, ensuring that it correctly calculates the number of working days while considering weekends, German holidays, and different date ranges. The `testSetup` method ensures that necessary data, such as German holidays, is set up before running the tests.