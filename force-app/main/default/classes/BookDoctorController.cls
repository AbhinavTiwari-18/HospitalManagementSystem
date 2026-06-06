public with sharing class BookDoctorController {

    // 🔹 GET AVAILABLE DOCTORS
    @AuraEnabled(cacheable=true)
    public static List<Employees__c> getAvailableDoctors(
        List<String> specializations,
        Datetime startDateTime,
        Datetime endDateTime
    ){

        if(specializations == null || specializations.isEmpty()){
            return new List<Employees__c>();
        }

        List<Employees__c> doctors = [
            SELECT Id, Name, Specialisation__c, Year_of_Experience__c
            FROM Employees__c
            WHERE Specialisation__c IN :specializations
        ];

        if(doctors.isEmpty()){
            return new List<Employees__c>();
        }

        Set<Id> doctorIds = new Set<Id>();
        for(Employees__c d : doctors){
            doctorIds.add(d.Id);
        }

        List<Appointment__c> booked = [
            SELECT Employee__c
            FROM Appointment__c
            WHERE Employee__c IN :doctorIds
            AND Start_Date__c < :endDateTime
            AND End_Date__c > :startDateTime
        ];

        Set<Id> busyDoctors = new Set<Id>();
        for(Appointment__c a : booked){
            busyDoctors.add(a.Employee__c);
        }

        List<Employees__c> availableDoctors = new List<Employees__c>();

        for(Employees__c d : doctors){
            if(!busyDoctors.contains(d.Id)){
                availableDoctors.add(d);
            }
        }

        return availableDoctors;
    }


    // 🔹 BOOK APPOINTMENT
    @AuraEnabled
    public static String bookAppointment(
        Id doctorId,
        Id patientId,
        Datetime startDateTime,
        Datetime endDateTime
    ){

        // 🔹 BASIC VALIDATION
        if(doctorId == null || patientId == null){
            throw new AuraHandledException('Doctor & Patient required');
        }

        if(startDateTime == null || endDateTime == null){
            throw new AuraHandledException('Select date/time');
        }

        if(startDateTime >= endDateTime){
            throw new AuraHandledException('Invalid time range');
        }

        // 🔥 MAX 3 MONTH (90 DAYS)
        Integer daysDiff = startDateTime.date().daysBetween(endDateTime.date());
        if(daysDiff > 90){
            throw new AuraHandledException('❌ Appointment cannot exceed 3 months (90 days)');
        }

        List<Appointment__c> toInsert = new List<Appointment__c>();

        Date startDate = startDateTime.date();
        Date endDate   = endDateTime.date();
        Date currentDate = startDate;

        while(currentDate <= endDate){

            // 🔹 DEFINE DAY START & END
            Datetime dayStart = (currentDate == startDate)
                ? startDateTime
                : Datetime.newInstance(currentDate, Time.newInstance(0,0,0,0));

            Datetime dayEnd = (currentDate == endDate)
                ? endDateTime
                : Datetime.newInstance(currentDate, Time.newInstance(23,59,59,0));

            // 🔥 MAX 6 HOURS PER DAY
            Decimal hours = (dayEnd.getTime() - dayStart.getTime()) / (1000 * 60 * 60);

            if(hours > 6){
                dayEnd = dayStart.addHours(6);
            }

            // 🔒 OVERLAP CHECK
            List<Appointment__c> existing = [
                SELECT Id
                FROM Appointment__c
                WHERE Employee__c = :doctorId
                AND Start_Date__c < :dayEnd
                AND End_Date__c > :dayStart
                LIMIT 1
            ];

            if(!existing.isEmpty()){
                throw new AuraHandledException(
                    '❌ Doctor not available on ' + String.valueOf(currentDate)
                );
            }

            // ✅ CREATE RECORD
            toInsert.add(new Appointment__c(
                Employee__c = doctorId,
                Patient__c = patientId,
                Start_Date__c = dayStart,
                End_Date__c = dayEnd
            ));

            currentDate = currentDate.addDays(1);
        }

        insert toInsert;

        return '✅ Appointments Created: ' + toInsert.size();
    }


    // 🔹 SEARCH PATIENT
    @AuraEnabled(cacheable=true)
    public static List<Patient__c> searchPatient(String searchKeyword) {

        if(String.isBlank(searchKeyword)){
            return new List<Patient__c>();
        }

        String searchPattern = '%' + searchKeyword + '%';

        return [
            SELECT Id, Name 
            FROM Patient__c 
            WHERE Name LIKE :searchPattern 
            LIMIT 10
        ];
    }
}