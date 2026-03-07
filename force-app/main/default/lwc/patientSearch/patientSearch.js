import { LightningElement, track } from 'lwc';
import searchPatients from '@salesforce/apex/PatientSearchController.searchPatients';

const COLUMNS = [
    { label: 'Patient Name', fieldName: 'Name' },
    { label: 'Phone', fieldName: 'Phone__c' },
    { label: 'Email', fieldName: 'Email__c' }
];

export default class PatientSearch extends LightningElement {

    searchKey = '';
    @track patients;
    columns = COLUMNS;

    handleSearchKey(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        searchPatients({ searchKey: this.searchKey }) // imperative call to apex
            .then(result => {
                this.patients = result;
            })
            .catch(error => {
                console.error(error);
            });
    }

}