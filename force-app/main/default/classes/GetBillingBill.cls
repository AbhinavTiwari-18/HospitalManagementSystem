@RestResource(urlMapping='/getbilling')
global with sharing class GetBillingBill {

    // 🔹 Request Wrapper (not used in GET but kept as you wrote)
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

    @HttpGet
    global static ResponseBody getBillingDetails() {

        RestRequest req = RestContext.request;

        // ✅ GET → take from URL params
        String patientId = req.params.get('patientId');

        ResponseBody res = new ResponseBody();

        try {
 
            if (String.isBlank(patientId)) {
                res.success = false;
                res.message = 'Patient Id is required';
                res.bills = new List<BillWrapper>();
                return res;
            }

            // 🔥 SAME QUERY (no change)
            List<Bills__c> billList = [
                SELECT Id, Name, Bill_Date__c, Payment_Mode__c,
                       (SELECT Id, Name, Price__c, Quantity__c  
                        FROM Bill_Line_Items__r)
                FROM Bills__c
                WHERE Patient__c = :patientId
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

                if (b.Bill_Line_Items__r != null) {

                    for (Bill_Line_Item__c item : b.Bill_Line_Items__r) {

                        BillLineItemWrapper iw = new BillLineItemWrapper();
                        iw.itemId = item.Id;
                        iw.itemName = item.Name;
                        iw.price = item.Price__c;
                        iw.quantity = item.Quantity__c;
                        bw.items.add(iw);
                    }
                }

                result.add(bw);
            }

            res.success = true;
            res.message = result.isEmpty() ? 'No bills found' : 'Billing data fetched successfully';
            res.bills = result;

        } catch (Exception e) {
            res.success = false;
            res.message = 'Error: ' + e.getMessage();
            res.bills = new List<BillWrapper>();
        }

        return res;
    }
}