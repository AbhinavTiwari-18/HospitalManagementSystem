trigger AppointmentDoctorValidation on Appointment__c (before insert, before update) {

    Set<Id> doctorIds = new Set<Id>();

    for(Appointment__c appt : Trigger.new){
        if(appt.Employee__c != null && appt.Start_Date__c != null){
            doctorIds.add(appt.Employee__c);
        }
    }

    if(doctorIds.isEmpty()) return;

    // Fetch only doctors
    Map<Id, Employees__c> doctorMap = new Map<Id, Employees__c>(
        [SELECT Id
         FROM Employees__c
         WHERE RecordTypeId = '012gL000004BUEzQAO'
         AND Id IN :doctorIds]
    );

    Set<Id> newIds = new Set<Id>();
    if(Trigger.isUpdate){
        newIds = Trigger.newMap.keySet();
    }

    // Fetch existing appointments
    List<Appointment__c> existingAppointments = [
        SELECT Id, Employee__c, Start_Date__c, End_Date__c
        FROM Appointment__c
        WHERE Employee__c IN :doctorMap.keySet()
        AND Id NOT IN :newIds
    ];

    // Group appointments by Doctor and Date
    Map<Id, Map<Date, List<Appointment__c>>> doctorSchedule = new Map<Id, Map<Date, List<Appointment__c>>>();

    for(Appointment__c appt : existingAppointments){

        Date apptDate = appt.Start_Date__c.date();

        if(!doctorSchedule.containsKey(appt.Employee__c)){
            doctorSchedule.put(appt.Employee__c, new Map<Date, List<Appointment__c>>());
        }

        if(!doctorSchedule.get(appt.Employee__c).containsKey(apptDate)){
            doctorSchedule.get(appt.Employee__c).put(apptDate, new List<Appointment__c>());
        }

        doctorSchedule.get(appt.Employee__c).get(apptDate).add(appt);
    }

    // Validate new appointments
    for(Appointment__c newAppt : Trigger.new){

        if(!doctorMap.containsKey(newAppt.Employee__c) ||
           newAppt.Start_Date__c == null ||
           newAppt.End_Date__c == null){
            continue;
        }

        Date apptDate = newAppt.Start_Date__c.date();

        if(!doctorSchedule.containsKey(newAppt.Employee__c)){
            doctorSchedule.put(newAppt.Employee__c, new Map<Date, List<Appointment__c>>());
        }

        if(!doctorSchedule.get(newAppt.Employee__c).containsKey(apptDate)){
            doctorSchedule.get(newAppt.Employee__c).put(apptDate, new List<Appointment__c>());
        }

        List<Appointment__c> sameDayAppointments =
            doctorSchedule.get(newAppt.Employee__c).get(apptDate);

        // Max 5 appointments rule
        if(sameDayAppointments.size() >= 5){
            newAppt.addError('Doctor cannot have more than 5 appointments per day.');
            continue;
        }

        // Check overlap
        for(Appointment__c oldAppt : sameDayAppointments){

            if(oldAppt.Start_Date__c < newAppt.End_Date__c &&
               oldAppt.End_Date__c > newAppt.Start_Date__c){

                newAppt.addError('Doctor already has an overlapping appointment.');
                break;
            }
        }

        // Add new appointment to schedule so bulk inserts are handled
        sameDayAppointments.add(newAppt);
    }
}