import { LightningElement, wire } from 'lwc';
import getAppointments from '@salesforce/apex/DoctorAppointmentsController.getAppointments';

const COLUMNS = [
    { label: 'Patient Name', fieldName: 'patientName' },
    { label: 'Start Time', fieldName: 'Start_Date__c', type: 'date' },
    { label: 'End Time', fieldName: 'End_Date__c', type: 'date' },
    { label: 'Employee Name', fieldName: 'employeeName' }
];

export default class DoctorAppointmentTodays extends LightningElement {

    columns = COLUMNS;
    appointments = [];
    error;

    selectedFilter = 'today';

    filterOptions = [
        { label: 'Today', value: 'today' },
        { label: 'Past', value: 'past' },
        { label: 'Future', value: 'future' }
    ];

    @wire(getAppointments, { filterType: '$selectedFilter' })
    wiredAppointments({ data, error }) {

        if (data) {

            this.appointments = data.map(record => ({
                Id: record.Id,
                Start_Date__c: record.Start_Date__c,
                End_Date__c: record.End_Date__c,
                patientName: record.Patient__r ? record.Patient__r.Name : '',
                employeeName: record.Employee__r ? record.Employee__r.Name : ''
            }));

            this.error = undefined;

        } else if (error) {
            this.error = error;
            this.appointments = [];
            console.error('Error fetching appointments:', error);
        }
    }

    handleFilterChange(event) {
        this.selectedFilter = event.detail.value;
    }
}