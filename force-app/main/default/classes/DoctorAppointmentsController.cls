public with sharing class DoctorAppointmentsController {

    @AuraEnabled(cacheable=true)
    public static List<Appointment__c> getAppointments(String filterType) {

        if(filterType == 'past'){
            return [
                SELECT Id, Name, Start_Date__c, End_Date__c,
                       Patient__r.Name,
                       Employee__r.Name
                FROM Appointment__c
                WHERE Start_Date__c < TODAY
                AND OwnerId = :UserInfo.getUserId()
                ORDER BY Start_Date__c DESC
            ];
        }

        if(filterType == 'future'){
            return [
                SELECT Id, Name, Start_Date__c, End_Date__c,
                       Patient__r.Name,
                       Employee__r.Name
                FROM Appointment__c
                WHERE Start_Date__c > TODAY
                AND OwnerId = :UserInfo.getUserId()
                ORDER BY Start_Date__c ASC
            ];
        }

        // Default → Today
        return [
            SELECT Id, Name, Start_Date__c, End_Date__c,
                   Patient__r.Name,
                   Employee__r.Name
            FROM Appointment__c
            WHERE Start_Date__c = TODAY
            AND OwnerId = :UserInfo.getUserId()
            ORDER BY Start_Date__c
        ];
    }
}