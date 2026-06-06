trigger AppointmentTrigger on Appointment__c (before insert, before update) {

    // 🔹 Collect doctor IDs
    Set<Id> doctorIds = new Set<Id>();

    for(Appointment__c appt : Trigger.new){
        if(appt.Employee__c != null){
            doctorIds.add(appt.Employee__c);
        }
    }

    // 🔹 If no doctors, exit
    if(doctorIds.isEmpty()){
        return;
    }

    // 🔹 Get existing appointments
    List<Appointment__c> existingAppointments = [
        SELECT Id, Employee__c, Start_Date__c, End_Date__c
        FROM Appointment__c
        WHERE Employee__c IN :doctorIds
    ];

    // 🔹 Validate overlap
    for(Appointment__c newAppt : Trigger.new){

        // Skip invalid records
        if(newAppt.Employee__c == null ||
           newAppt.Start_Date__c == null ||
           newAppt.End_Date__c == null){
            continue;
        }

        for(Appointment__c ex : existingAppointments){

            // Skip same record (for update)
            if(ex.Id == newAppt.Id){
                continue;
            }

            // 🔥 OVERLAP CONDITION
            if(ex.Employee__c == newAppt.Employee__c &&
               ex.Start_Date__c < newAppt.End_Date__c &&
               ex.End_Date__c > newAppt.Start_Date__c){

                newAppt.addError(
                    '❌ Appointment overlaps with existing booking'
                );
            }
        }
    }
}