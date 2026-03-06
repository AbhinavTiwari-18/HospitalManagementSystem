public with sharing class PatientSearchController {

    @AuraEnabled(cacheable=true)
    public static List<Patient__c> searchPatients(String searchKey) {

        if(String.isBlank(searchKey)){
            return new List<Patient__c>();
        }

        return [
            SELECT Id, Name, Phone__c, Email__c
            FROM Patient__c
            WHERE Name LIKE :('%' + searchKey + '%')
            LIMIT 20
        ];
    }

}