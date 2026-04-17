import { LightningElement, track } from 'lwc';
import getAvailableDoctors from '@salesforce/apex/BookDoctorController.getAvailableDoctors';
import bookAppointment from '@salesforce/apex/BookDoctorController.bookAppointment';
import searchPatient from '@salesforce/apex/BookDoctorController.searchPatient';

export default class BookDoctor extends LightningElement {

    @track startDateTime;
    @track endDateTime;
    @track selectedSpecializations = [];
    @track doctors;

    @track selectedPatientId;
    @track patientName = '';
    @track patients = [];

    selectedDoctorId;
    delayTimeout;
    isLoading = false;

    @track showSearchForm = true;
    @track showDoctorList = false;

    specializationOptions = [
        { label: 'General Medicine', value: 'General Medicine' },
        { label: 'Cardiology', value: 'Cardiology' },
        { label: 'Neurology', value: 'Neurology' },
        { label: 'Orthopedics', value: 'Orthopedics' },
        { label: 'Pediatrics', value: 'Pediatrics' },
        { label: 'Dermatology', value: 'Dermatology' },
        { label: 'Gynecology', value: 'Gynecology' },
        { label: 'Oncology', value: 'Oncology' },
        { label: 'Psychiatry', value: 'Psychiatry' },
        { label: 'Ophthalmology', value: 'Ophthalmology' },
        { label: 'ENT (Ear Nose Throat)', value: 'ENT (Ear Nose Throat)' },
        { label: 'Urology', value: 'Urology' },
        { label: 'Nephrology', value: 'Nephrology' },
        { label: 'Gastroenterology', value: 'Gastroenterology' },
        { label: 'Pulmonology', value: 'Pulmonology' },
        { label: 'Endocrinology', value: 'Endocrinology' },
        { label: 'Radiology', value: 'Radiology' },
        { label: 'Anesthesiology', value: 'Anesthesiology' },
        { label: 'Emergency Medicine', value: 'Emergency Medicine' },
        { label: 'General Surgery', value: 'General Surgery' },
        { label: 'Plastic Surgery', value: 'Plastic Surgery' },
        { label: 'Cardiac Surgery', value: 'Cardiac Surgery' },
        { label: 'Neurosurgery', value: 'Neurosurgery' }
    ];

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Experience', fieldName: 'Year_of_Experience__c' },
        { label: 'Specialization', fieldName: 'Specialisation__c' }
    ];

    handleStartChange(e){ this.startDateTime = e.target.value; }
    handleEndChange(e){ this.endDateTime = e.target.value; }
    handleSpecChange(e){ this.selectedSpecializations = e.detail.value; }

    // 🔥 ONLY FIXED FUNCTION
    handlePatientSearch(event){

        const value = event.target.value;
        this.patientName = value;

        console.log('Typing:', value);

        clearTimeout(this.delayTimeout);

        this.delayTimeout = setTimeout(() => {

            console.log('Debounce Triggered:', value);

            if(!value || value.length < 4){
                console.warn('Less than 4 characters');
                this.patients = [];
                return;
            }

            console.log('Calling Apex...');

            searchPatient({ searchKeyword: value })
            .then(result => {

                console.log('Patients from Apex:', result);

                if(result && result.length > 0){
                    this.patients = result;
                } else {
                    console.warn('No patients found');
                    this.patients = [];
                }

            })
            .catch(error => {
                console.error('Patient error:', JSON.stringify(error));
                this.patients = [];
            });

        }, 400);
    }

    // 🔥 SAFE SELECT (UNCHANGED)
    handlePatientSelect(event){

        try{

            const id = event.currentTarget?.dataset?.id;
            const name = event.currentTarget?.dataset?.name;

            if(!id){
                console.error('No patient id');
                return;
            }

            this.selectedPatientId = id;
            this.patientName = name;

            this.patients = [];

        }catch(e){
            console.error('Select error:', e);
        }
    }

    // 🔹 SEARCH DOCTORS (UNCHANGED)
    searchDoctors(){

        if(!this.selectedPatientId){
            alert('Select patient');
            return;
        }

        if(!this.startDateTime || !this.endDateTime){
            alert('Select time');
            return;
        }

        if(this.selectedSpecializations.length === 0){
            alert('Select specialization');
            return;
        }

        getAvailableDoctors({
            specializations: this.selectedSpecializations,
            startDateTime: this.startDateTime,
            endDateTime: this.endDateTime
        })
        .then(result => {

            this.doctors = result;

            if(result.length > 0){
                this.showSearchForm = false;
                this.showDoctorList = true;
            } else {
                alert('No doctors available');
            }
        })
        .catch(error => console.error(error));
    }

    handleRowSelection(event){
        this.selectedDoctorId = event.detail.selectedRows[0]?.Id;
    }

    handleBack(){
        this.showDoctorList = false;
        this.showSearchForm = true;
    }

    // 🔹 BOOK APPOINTMENT (UNCHANGED)
    bookAppointment(){

        if(!this.selectedDoctorId){
            alert('Select doctor');
            return;
        }

        if(!this.selectedPatientId){
            alert('Select patient');
            return;
        }

        bookAppointment({
            doctorId: this.selectedDoctorId,
            patientId: this.selectedPatientId,
            startDateTime: this.startDateTime,
            endDateTime: this.endDateTime
        })
        .then(result => {

            alert(result);

            this.showDoctorList = false;
            this.showSearchForm = true;

            this.selectedDoctorId = null;
            this.doctors = null;
        })
        .catch(error => alert(error.body.message));
    }

    bookAppointment(){

    console.log('🚀 bookAppointment() triggered');

    console.log('📌 Selected Doctor:', this.selectedDoctorId);
    console.log('📌 Selected Patient:', this.selectedPatientId);
    console.log('📌 Start DateTime:', this.startDateTime);
    console.log('📌 End DateTime:', this.endDateTime);

    // 🔥 VALIDATION
    if(!this.selectedDoctorId){
        console.error('❌ Doctor not selected');
        alert('Select doctor');
        return;
    }

    if(!this.selectedPatientId){
        console.error('❌ Patient not selected');
        alert('Select patient');
        return;
    }

    if(!this.startDateTime || !this.endDateTime){
        console.error('❌ Date/Time missing');
        alert('Select date & time');
        return;
    }

    console.log('📤 Sending data to Apex...', {
        doctorId: this.selectedDoctorId,
        patientId: this.selectedPatientId,
        startDateTime: this.startDateTime,
        endDateTime: this.endDateTime
    });

    bookAppointment({
        doctorId: this.selectedDoctorId,
        patientId: this.selectedPatientId,
        startDateTime: this.startDateTime,
        endDateTime: this.endDateTime
    })
    .then(result => {

        console.log('✅ SUCCESS RESPONSE:', result);

        alert(result);

        console.log('🔄 Resetting UI');

        this.showDoctorList = false;
        this.showSearchForm = true;

        this.selectedDoctorId = null;
        this.doctors = null;

    })
    .catch(error => {

        console.error('❌ FULL ERROR OBJECT:', JSON.stringify(error));

        let message = 'Something went wrong';

        // 🔥 SAFE ERROR HANDLING
        if(error?.body?.message){
            message = error.body.message;
        } 
        else if(error?.message){
            message = error.message;
        }

        console.error('❌ FINAL ERROR MESSAGE:', message);

        alert(message);
     });
    }
}