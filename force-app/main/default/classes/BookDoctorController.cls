public with sharing class BookDoctorController {

    @AuraEnabled(cacheable=true)
    public static List<Employees__c> getAvailableDoctors(
        List<String> specializations,
        Datetime startDateTime,
        Datetime endDateTime
    ){

        if(specializations == null || specializations.isEmpty()){
            System.debug('❌ No specializations provided');
            return new List<Employees__c>();
        }

        // 1️⃣ Get doctors
        List<Employees__c> doctors = [
            SELECT Id, Name, Specialisation__c, Year_of_Experience__c
            FROM Employees__c
            WHERE Specialisation__c IN :specializations
        ];

        if(doctors.isEmpty()){
            return new List<Employees__c>();
        }

        // 2️⃣ Collect doctor IDs
        Set<Id> doctorIds = new Set<Id>();
        for(Employees__c d : doctors){
            doctorIds.add(d.Id);
        }

        // 3️⃣ Get overlapping appointments
        List<Appointment__c> booked = [
            SELECT Employee__c, Start_Date__c, End_Date__c
            FROM Appointment__c
            WHERE Employee__c IN :doctorIds
            AND Start_Date__c < :endDateTime
            AND End_Date__c > :startDateTime
        ];


        // 4️⃣ Busy doctors
        Set<Id> busyDoctors = new Set<Id>();
        for(Appointment__c a : booked){
            busyDoctors.add(a.Employee__c);
        }

        System.debug('⛔ Busy Doctors: ' + busyDoctors);

        // 5️⃣ Filter available
        List<Employees__c> availableDoctors = new List<Employees__c>();

        for(Employees__c d : doctors){
            if(!busyDoctors.contains(d.Id)){
                availableDoctors.add(d);
            }
        }

        System.debug('✅ Available Doctors: ' + availableDoctors.size());

        return availableDoctors;
    }


     // Book Appointment Method
    @AuraEnabled
public static String bookAppointment(
    Id doctorId,
    Id patientId,
    Datetime startDateTime,
    Datetime endDateTime
){

    System.debug('🚀 Booking Appointment');

    // 🔥 VALIDATION
    if(doctorId == null){
        throw new AuraHandledException('Please select a doctor');
    }

    if(patientId == null){
        throw new AuraHandledException('Please select a patient');
    }

    if(startDateTime == null || endDateTime == null){
        throw new AuraHandledException('Please select date/time');
    }

    // 🔥 EXTRA SAFETY (IMPORTANT)
    if(startDateTime >= endDateTime){
        throw new AuraHandledException('End time must be after start time');
    }

    try{

        // 🔒 CHECK OVERLAPPING
        List<Appointment__c> existing = [
            SELECT Id
            FROM Appointment__c
            WHERE Employee__c = :doctorId
            AND Start_Date__c < :endDateTime
            AND End_Date__c > :startDateTime
            LIMIT 1
        ];

        if(!existing.isEmpty()){
            throw new AuraHandledException('Doctor not available for selected time');
        }

        // ✅ CREATE APPOINTMENT
        Appointment__c appt = new Appointment__c();
        appt.Employee__c = doctorId;
        appt.Patient__c = patientId;
        appt.Start_Date__c = startDateTime;
        appt.End_Date__c = endDateTime;

        insert appt;

        System.debug('✅ Appointment Created: ' + appt.Id);

        return 'Appointment Booked Successfully';

    }catch(Exception e){

        System.debug('❌ Error: ' + e.getMessage());

        // 🔥 Always return clean error to LWC
        throw new AuraHandledException(e.getMessage());
    }
}   
    
    @AuraEnabled(cacheable=true)
     public static List<Patient__c> searchPatient(String searchKeyword) {
        String searchPattern = '%' + searchKeyword + '%';
        return [SELECT Id, Name FROM Patient__c WHERE Name LIKE :searchPattern LIMIT 10];

    }


}