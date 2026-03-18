@RestResource(urlMapping='/v1/patient/register')
global with sharing class registerPatient {

    @HttpPost
    global static ResponseWrapper registerPatient() {

        ResponseWrapper res = new ResponseWrapper();

        try {

            // ✅ Read raw JSON
            String body = RestContext.request.requestBody.toString();

            // ✅ Deserialize manually
            RequestWrapper req = (RequestWrapper) JSON.deserialize(body, RequestWrapper.class);

            // ✅ Validation
            if(String.isBlank(req.name)) {
                throw new CustomException('Patient Name is required');
            }

            if(String.isBlank(req.phone)) {
                throw new CustomException('Phone is required');
            }

            // ✅ Create record
            Patient__c patient = new Patient__c();

            patient.Name = req.name;
            patient.Phone__c = req.phone;
            patient.Email__c = req.email;
            patient.DOB__c = req.dob;
            patient.Address__c = req.address;

            // ✅ Picklist validation
            patient.Gender__c = validatePicklist('Patient__c', 'Gender__c', req.gender);
            patient.Blood_Group__c = validatePicklist('Patient__c', 'Blood_Group__c', req.bloodGroup);
            patient.ConditionType__c = validatePicklist('Patient__c', 'ConditionType__c', req.conditionType);
            patient.Status__c = validatePicklist('Patient__c', 'Status__c', req.status);

            // ✅ Multi picklist
            patient.TreatmentType__c = validateMultiPicklist(
                'Patient__c',
                'TreatmentType__c',
                req.treatmentType
            );

            insert patient;

            res.success = true;
            res.message = 'Patient Registered Successfully';
            res.patientId = patient.Id;

        } catch(Exception e) {
            res.success = false;
            res.message = e.getMessage();
        }

        return res;
    }

    // ================================
    // PICKLIST VALIDATION
    // ================================
    private static String validatePicklist(String obj, String field, String value) {

        if(String.isBlank(value)) return null;

        List<Schema.PicklistEntry> values =
            Schema.getGlobalDescribe().get(obj)
            .getDescribe()
            .fields.getMap().get(field)
            .getDescribe()
            .getPicklistValues();

        for(Schema.PicklistEntry p : values) {
            if(p.getValue() == value) {
                return value;
            }
        }

        throw new CustomException('Invalid value for ' + field + ': ' + value);
    }

    // ================================
    // MULTI PICKLIST
    // ================================
    private static String validateMultiPicklist(String obj, String field, List<String> vals) {

        if(vals == null || vals.isEmpty()) return null;

        Set<String> valid = new Set<String>();

        List<Schema.PicklistEntry> values =
            Schema.getGlobalDescribe().get(obj)
            .getDescribe()
            .fields.getMap().get(field)
            .getDescribe()
            .getPicklistValues();

        for(Schema.PicklistEntry p : values) {
            valid.add(p.getValue());
        }

        for(String v : vals) {
            if(!valid.contains(v)) {
                throw new CustomException('Invalid multi-picklist value: ' + v);
            }
        }

        return String.join(vals, ';');
    }

    // ================================
    // REQUEST
    // ================================
    global class RequestWrapper {
        public String name;
        public String phone;
        public String email;
        public Date dob;
        public String address;

        public String gender;
        public String bloodGroup;
        public String conditionType;
        public String status;

        public List<String> treatmentType;
    }

    // ================================
    // RESPONSE
    // ================================
    global class ResponseWrapper {
        public Boolean success;
        public String message;
        public String patientId;
    }

    global class CustomException extends Exception {}
}