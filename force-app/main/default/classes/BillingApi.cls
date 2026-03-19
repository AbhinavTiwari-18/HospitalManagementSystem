@RestResource(urlMapping='/billing')
global with sharing class BillingApi {

    // 🔹 Request Wrapper
    global class RequestBody {
        public String patientId;
    }

    // 🔹 Bill Line Item Wrapper
    global class BillLineItemWrapper {
        public String itemId;
        public String itemName;
        public Decimal price;
        public Decimal quantity;
        public String paymentStatus;
    }

    // 🔹 Bill Wrapper
    global class BillWrapper {
        public String billId;
        public String billNumber;
        public Date billDate;
        public String paymentMode;
        public List<BillLineItemWrapper> items;
    }

    // 🔹 Response Wrapper
    global class ResponseBody {
        public Boolean success;
        public String message;
        public List<BillWrapper> bills;
    }

    @HttpPost
    global static ResponseBody getBillingDetails() {

        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();

        ResponseBody res = new ResponseBody();

        try {
            RequestBody data = (RequestBody) JSON.deserialize(body, RequestBody.class);

            if (String.isBlank(data.patientId)) {
                res.success = false;
                res.message = 'Patient Id is required';
                return res;
            }

            // 🔥 MAIN QUERY (Parent + Child)
            List<Bills__c> billList = [
                SELECT Id, Name, Bill_Date__c, Payment_Mode__c, 
                       (SELECT Id, Name, Price__c, Quantity__c  
                        FROM Bill_Line_Items__r)
                FROM Bills__c
                WHERE Patient__c = :data.patientId
                ORDER BY Bill_Date__c DESC
            ];

            List<BillWrapper> result = new List<BillWrapper>();

            for (Bills__c b : billList) {

                BillWrapper bw = new BillWrapper();
                bw.billId = b.Id;
                bw.billNumber = b.Name;
                bw.billDate = b.Bill_Date__c;
                bw.paymentMode = b.Payment_Mode__c;

                bw.items = new List<BillLineItemWrapper>();

                for (Bill_Line_Item__c item : b.Bill_Line_Items__r) {

                    BillLineItemWrapper iw = new BillLineItemWrapper();
                    iw.itemId = item.Id;
                    iw.itemName = item.Name;
                    iw.price = item.Price__c;
                    iw.quantity = item.Quantity__c;
                    bw.items.add(iw);
                }

                result.add(bw);
            }

            res.success = true;
            res.message = 'Billing data fetched successfully';
            res.bills = result;

        } catch (Exception e) {
            res.success = false;
            res.message = 'Error: ' + e.getMessage();
        }

        return res;
    }
}