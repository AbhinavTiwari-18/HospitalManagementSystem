trigger AppointmentDoctorValidation on Appointment__c (before insert, before update) {

    
    for(Appointment__c appointment : Trigger.new) {
        if(appointment.Doctor__c != null) {
            appointment.Doctor__c.addError('Doctor cannot be changed');
        }


    }
} 