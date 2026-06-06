public with sharing class DoctorDashboardController {

    @AuraEnabled(cacheable=true)
    public static List<Employees__c> searchDoctors(String keyword){

        if(String.isBlank(keyword)){
            return new List<Employees__c>();
        }

        String searchKey = '%' + keyword + '%';

        return [

            SELECT Id,
                   Name

            FROM Employees__c

            WHERE Name LIKE :searchKey

            ORDER BY Name

            LIMIT 5
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Appointment__c>
    getUpcomingAppointments(Id doctorId){

        if(doctorId == null){
            return new List<Appointment__c>();
        }

        return [

            SELECT Id,
                   Name,
                   Patient__c,
                   Patient__r.Name,
                   Employee__c,
                   Employee__r.Name,
                   Start_Date__c,
                   End_Date__c,
                   Status__c

            FROM Appointment__c

            WHERE Employee__c = :doctorId
            AND Start_Date__c >= TODAY
            AND Status__c != 'Cancelled'

            ORDER BY Start_Date__c ASC
        ];
    }

    @AuraEnabled
    public static void cancelAppointment(
        Id appointmentId,
        String reason
    ){

        Appointment__c app = [

            SELECT Id,
                   Status__c,
                   Cancel_Reason__c

            FROM Appointment__c

            WHERE Id = :appointmentId

            LIMIT 1
        ];

        app.Status__c = 'Cancelled';

        app.Cancel_Reason__c = reason;

        update app;
    }
}