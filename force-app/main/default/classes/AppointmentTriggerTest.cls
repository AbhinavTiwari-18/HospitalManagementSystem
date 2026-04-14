@isTest
public class AppointmentTriggerTest{

    @isTest
    static void testAppointmentScenarios() {

        // 1️⃣ Create base appointment (Valid)
        Appointment__c app1 = new Appointment__c(
            Name = 'Test Appointment 1',
            Start_Date__c = Datetime.now(),
            End_Date__c = Datetime.now().addHours(1)
        );

        insert app1;

        // 2️⃣ Overlapping appointment (Should FAIL)
        Appointment__c app2 = new Appointment__c(
            Name = 'Overlap Appointment',
            Start_Date__c = app1.Start_Date__c.addMinutes(30),
            End_Date__c = app1.End_Date__c.addHours(1)
        );

        try {
            insert app2;
            System.assert(false, 'Expected overlap error but insert succeeded');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('overlaps'), 'Wrong error message');
        }

        // 3️⃣ Invalid Time (End < Start)
        Appointment__c app3 = new Appointment__c(
            Name = 'Invalid Time',
            Start_Date__c = Datetime.now(),
            End_Date__c = Datetime.now().addHours(-1)
        );

        try {
            insert app3;
            System.assert(false, 'Expected validation error but insert succeeded');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('End time'), 'Wrong error message');
        }

        // 4️⃣ Edge Case (End == Start → should pass)
        Appointment__c app4 = new Appointment__c(
            Name = 'Edge Case',
            Start_Date__c = app1.End_Date__c,
            End_Date__c = app1.End_Date__c.addHours(1)
        );

        insert app4;

        System.assertNotEquals(null, app4.Id, 'Edge case insert failed');
    }
}