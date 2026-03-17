@RestResource(urlMapping='/login')
global with sharing class PatientLoginAPI {

    global class LoginRequest {
        public String phone;
    }

    global class LoginResponse {
        public Boolean success;
        public String message;
        public String patientId;
        public String patientName;
        public String phone;
    }

    @HttpPost
    global static LoginResponse login() {

        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();

        LoginResponse res = new LoginResponse();

        try {
            LoginRequest data = (LoginRequest) JSON.deserialize(body, LoginRequest.class);

            if (String.isBlank(data.phone)) {
                res.success = false;
                res.message = 'Phone number is required';
                return res;
            }

            List<Patient__c> patients = [
                SELECT Id, Name, Phone__c
                FROM Patient__c
                WHERE Phone__c = :data.phone
                LIMIT 1
            ];

            if (!patients.isEmpty()) {
                Patient__c p = patients[0];

                res.success = true;
                res.message = 'Patient found';
                res.patientId = p.Id;
                res.patientName = p.Name;
                res.phone = p.Phone__c;

            } else {
                res.success = false;
                res.message = 'Patient does not exist';
            }

        } catch (Exception e) {
            res.success = false;
            res.message = 'Error: ' + e.getMessage();
        }

        return res;
    }
}
