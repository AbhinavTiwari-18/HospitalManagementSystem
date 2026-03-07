trigger PreventDuplicateAppointment on Appointment__c (before insert, before update) {

    Set<Id> doctorIds = new Set<Id>();
    Set<Id> patientIds = new Set<Id>();

    for(Appointment__c appt : Trigger.new){
        if(appt.Employee__c != null && appt.Patient__c != null){
            doctorIds.add(appt.Employee__c);
            patientIds.add(appt.Patient__c);
        }
    }

    if(doctorIds.isEmpty() || patientIds.isEmpty()) return;

    Set<Id> newIds = Trigger.isUpdate ? Trigger.newMap.keySet() : new Set<Id>();

    List<Appointment__c> existingAppointments = [
        SELECT Id, Employee__c, Patient__c, Start_Date__c
        FROM Appointment__c
        WHERE Employee__c IN :doctorIds
        AND Patient__c IN :patientIds
        AND Id NOT IN :newIds
    ];

    for(Appointment__c newAppt : Trigger.new){

        if(newAppt.Employee__c == null || newAppt.Patient__c == null || newAppt.Start_Date__c == null){
            continue;
        }

        Date newDate = newAppt.Start_Date__c.date();

        for(Appointment__c oldAppt : existingAppointments){

            if(oldAppt.Employee__c == newAppt.Employee__c &&
               oldAppt.Patient__c == newAppt.Patient__c &&
               oldAppt.Start_Date__c.date() == newDate){

                newAppt.addError('Patient already has an appointment with this doctor on the same day.');
                break;
            }
        }
    }
}