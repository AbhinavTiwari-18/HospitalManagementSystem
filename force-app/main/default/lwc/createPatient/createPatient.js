import { LightningElement, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

// Object
import PATIENT_OBJECT from '@salesforce/schema/Patient__c';

// Fields
import NAME_FIELD from '@salesforce/schema/Patient__c.Name';
import DOB_FIELD from '@salesforce/schema/Patient__c.DOB__c';
import GENDER_FIELD from '@salesforce/schema/Patient__c.Gender__c';
import EMAIL_FIELD from '@salesforce/schema/Patient__c.Email__c';
import PHONE_FIELD from '@salesforce/schema/Patient__c.Phone__c';
import ADDRESS_FIELD from '@salesforce/schema/Patient__c.Address__c';
import BLOOD_FIELD from '@salesforce/schema/Patient__c.Blood_Group__c';
import CONDITION_FIELD from '@salesforce/schema/Patient__c.ConditionType__c';
import STATUS_FIELD from '@salesforce/schema/Patient__c.Status__c';

export default class CreatePatient extends LightningElement {

    // =====================
    // FORM FIELDS
    // =====================
    name = '';
    dob = '';
    gender = '';
    email = '';
    phone = '';
    address = '';
    bloodGroup = '';
    conditionType = 'Normal'; // default
    status = 'Active';        // default

    // =====================
    // PICKLIST OPTIONS
    // =====================
    bloodGroupOptions = [];
    conditionOptions = [];
    statusOptions = [];

    genderOptions = [
        { label: 'Male', value: 'Male' },
        { label: 'Female', value: 'Female' },
        { label: 'Other', value: 'Other' }
    ];

    // =====================
    // OBJECT INFO
    // =====================
    @wire(getObjectInfo, { objectApiName: PATIENT_OBJECT })
    objectInfo;

    // =====================
    // DYNAMIC PICKLISTS
    // =====================

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: BLOOD_FIELD
    })
    bloodPicklistHandler({ data, error }) {
        if (data) {
            this.bloodGroupOptions = data.values;
        } else if (error) {
            console.error('Blood Picklist Error', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: CONDITION_FIELD
    })
    conditionPicklistHandler({ data, error }) {
        if (data) {
            this.conditionOptions = data.values;
        } else if (error) {
            console.error('Condition Picklist Error', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    statusPicklistHandler({ data, error }) {
        if (data) {
            this.statusOptions = data.values;
        } else if (error) {
            console.error('Status Picklist Error', error);
        }
    }

    // =====================
    // HANDLE INPUT CHANGE
    // =====================
    handleChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    // =====================
    // CREATE PATIENT
    // =====================
    createPatient() {

        // Basic Validation
        if (!this.name) {
            this.showToast('Error', 'Patient Name is required', 'error');
            return;
        }

        const fields = {};

        fields[NAME_FIELD.fieldApiName] = this.name;
        fields[DOB_FIELD.fieldApiName] = this.dob || null;
        fields[GENDER_FIELD.fieldApiName] = this.gender || null;
        fields[EMAIL_FIELD.fieldApiName] = this.email || null;
        fields[PHONE_FIELD.fieldApiName] = this.phone || null;
        fields[ADDRESS_FIELD.fieldApiName] = this.address || null;
        fields[BLOOD_FIELD.fieldApiName] = this.bloodGroup || null;
        fields[CONDITION_FIELD.fieldApiName] = this.conditionType || 'Normal';
        fields[STATUS_FIELD.fieldApiName] = this.status || 'Active';

        const recordInput = {
            apiName: PATIENT_OBJECT.objectApiName,
            fields: fields
        };

        createRecord(recordInput)
            .then(result => {
                this.showToast('Success', 'Patient Created Successfully', 'success');
                console.log('Created Record Id:', result.id);
                this.clearForm();
            })
            .catch(error => {
                console.error('Create Error:', error);

                let message = 'Error creating patient';

                // 🔥 Handle Duplicate Rule / Validation Errors
                if (error.body) {
                    if (error.body.output && error.body.output.errors.length > 0) {
                        message = error.body.output.errors[0].message;
                    } else if (error.body.message) {
                        message = error.body.message;
                    }
                }

                this.showToast('Error', message, 'error');
            });
    }

    // =====================
    // CLEAR FORM
    // =====================
    clearForm() {
        this.name = '';
        this.dob = '';
        this.gender = '';
        this.email = '';
        this.phone = '';
        this.address = '';
        this.bloodGroup = '';
        this.conditionType = 'Normal';
        this.status = 'Active';
    }

    // =====================
    // TOAST
    // =====================
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}