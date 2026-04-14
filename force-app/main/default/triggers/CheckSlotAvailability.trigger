trigger CheckSlotAvailability on Appointment__c (before insert, before update) {

    List<Appointment__c> newAppointments = Trigger.new;

    // Collect time ranges
    List<Datetime> startTimes = new List<Datetime>();
    List<Datetime> endTimes = new List<Datetime>();

    for (Appointment__c app : newAppointments) {
        if (app.Start_Date__c != null && app.End_Date__c != null) {
            startTimes.add(app.Start_Date__c);
            endTimes.add(app.End_Date__c);
        }
    }

    // Fetch possible overlapping appointments
    List<Appointment__c> existingAppointments = [
        SELECT Id, Start_Date__c, End_Date__c
        FROM Appointment__c
        WHERE Start_Date__c < :endTimes
        AND End_Date__c > :startTimes
    ];

    // Check overlap
    for (Appointment__c newApp : newAppointments) {

        if (newApp.Start_Date__c == null || newApp.End_Date__c == null) continue;

        for (Appointment__c existing : existingAppointments) {

            if (newApp.Id != existing.Id &&
                newApp.Start_Date__c < existing.End_Date__c &&
                newApp.End_Date__c > existing.Start_Date__c) {

                newApp.addError('❌ This appointment overlaps with an existing booking.');
            }
        }
    }
}