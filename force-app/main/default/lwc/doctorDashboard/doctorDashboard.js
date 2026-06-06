import { LightningElement, track } from 'lwc';

import searchDoctors
from '@salesforce/apex/DoctorDashboardController.searchDoctors';

import getUpcomingAppointments
from '@salesforce/apex/DoctorDashboardController.getUpcomingAppointments';

import cancelAppointment
from '@salesforce/apex/DoctorDashboardController.cancelAppointment';

import { ShowToastEvent }
from 'lightning/platformShowToastEvent';

const actions = [
    { label: 'Cancel', name: 'cancel' }
];

const columns = [

    {
        label: 'Appointment Name',
        fieldName: 'Name'
    },

    {
        label: 'Patient',
        fieldName: 'patientName'
    },

    {
        label: 'Doctor',
        fieldName: 'doctorName'
    },

    {
        label: 'Start Date',
        fieldName: 'Start_Date__c',
        type: 'date'
    },

    {
        label: 'End Date',
        fieldName: 'End_Date__c',
        type: 'date'
    },

    {
        label: 'Status',
        fieldName: 'Status__c'
    },

    {
        type: 'action',
        typeAttributes: {
            rowActions: actions
        }
    }
];

export default class DoctorDashboard extends LightningElement {

    @track appointments = [];

    @track doctorSuggestions = [];

    columns = columns;

    doctorName = '';

    selectedDoctorId;

    showSuggestions = false;

    showModal = false;

    selectedAppointmentId;

    cancelReason = '';

    noRecords = false;

    delayTimeout;

    handleDoctorChange(event){

        this.doctorName = event.target.value;

        window.clearTimeout(this.delayTimeout);

        this.delayTimeout = setTimeout(() => {

            if(this.doctorName.length >= 2){

                searchDoctors({
                    keyword: this.doctorName
                })

                .then(result => {

                    console.log('Doctor Search Result');

                    console.log(JSON.stringify(result));

                    this.doctorSuggestions = result;

                    this.showSuggestions = result.length > 0;
                })

                .catch(error => {

                    this.logError('Doctor Search Error', error);
                });
            }
            else{

                this.doctorSuggestions = [];

                this.showSuggestions = false;
            }

        }, 500);
    }

    handleDoctorSelect(event){

        this.selectedDoctorId =
            event.currentTarget.dataset.id;

        this.doctorName =
            event.currentTarget.dataset.name;

        console.log('Selected Doctor Id');

        console.log(this.selectedDoctorId);

        console.log('Selected Doctor Name');

        console.log(this.doctorName);

        this.showSuggestions = false;

        this.searchAppointments();
    }

    searchAppointments(){

        if(!this.selectedDoctorId){

            console.log('Doctor Id Missing');

            return;
        }

        getUpcomingAppointments({
            doctorId: this.selectedDoctorId
        })

        .then(result => {

            console.log('Appointments Loaded');

            console.log(JSON.stringify(result));

            this.appointments = result.map(row => {

                return {

                    ...row,

                    patientName:
                        row.Patient__r
                        ? row.Patient__r.Name
                        : '',

                    doctorName:
                        row.Employee__r
                        ? row.Employee__r.Name
                        : ''
                };
            });

            this.noRecords = result.length === 0;

            console.log('Formatted Appointments');

            console.log(JSON.stringify(this.appointments));

        })

        .catch(error => {

            this.logError(
                'Appointment Load Error',
                error
            );

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error loading appointments',
                    variant: 'error'
                })
            );
        });
    }

    handleRowAction(event){

        const actionName =
            event.detail.action.name;

        const row =
            event.detail.row;

        console.log('Row Action');

        console.log(actionName);

        console.log(JSON.stringify(row));

        if(actionName === 'cancel'){

            this.selectedAppointmentId = row.Id;

            this.showModal = true;
        }
    }

    handleReasonChange(event){

        this.cancelReason = event.target.value;

        console.log('Cancel Reason');

        console.log(this.cancelReason);
    }

    closeModal(){

        this.showModal = false;

        this.cancelReason = '';

        console.log('Modal Closed');
    }

    confirmCancel(){

        if(!this.cancelReason){

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message:
                        'Please Enter Cancellation Reason',
                    variant: 'error'
                })
            );

            return;
        }

        console.log('Cancelling Appointment');

        console.log(this.selectedAppointmentId);

        console.log(this.cancelReason);

        cancelAppointment({

            appointmentId:
                this.selectedAppointmentId,

            reason:
                this.cancelReason
        })

        .then(() => {

            console.log(
                'Appointment Cancelled Successfully'
            );

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message:
                        'Appointment Cancelled Successfully',
                    variant: 'success'
                })
            );

            this.closeModal();

            this.searchAppointments();
        })

        .catch(error => {

            this.logError(
                'Cancel Appointment Error',
                error
            );

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message:
                        'Error cancelling appointment',
                    variant: 'error'
                })
            );
        });
    }

    logError(title, error){

        console.error('====================');

        console.error(title);

        console.error('FULL ERROR');

        console.error(JSON.stringify(error));

        console.error('ERROR BODY');

        console.error(error?.body);

        console.error('ERROR MESSAGE');

        console.error(error?.body?.message);

        console.error('STACK');

        console.error(error?.stack);

        console.error('====================');
    }
}