import { LightningElement, track, api, wire } from 'lwc';
import saveLeaveApplication from '@salesforce/apex/LeaveApplicationController.saveLeaveApplication';
import getVacationBalance from '@salesforce/apex/LeaveApplicationController.getVacationBalance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeaveApplications from '@salesforce/apex/LeaveApplicationController.getLeaveApplications';
import { refreshApex } from '@salesforce/apex';


const columns = [
    { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    { label: 'Duration', fieldName: 'Duration__c', type: 'number' },
    { label: 'Type', fieldName: 'Type__c', type: 'text' }
];

export default class LeaveApplicationComponent extends LightningElement {
    @track leaveType;
    @track startDate;
    @track endDate;
    @track vacationBalance;

    columns = columns;
    leaveApplications;
    error;

    @wire(getLeaveApplications)
    wiredLeaveApplications({ error, data }) {
        if (data) {
            this.leaveApplications = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.leaveApplications = undefined;
        }
    }
    leaveTypeOptions = [
        { label: 'Vacation', value: 'Vacation' },
        { label: 'Business Trip', value: 'Business Trip' },
        { label: 'Other', value: 'Other' }
    ];



    connectedCallback() {
        this.fetchVacationBalance();
    }



    get columns() {
        return columns;
    }
    handleTypeChange(event) {
        this.leaveType = event.detail.value;
    }

    handleStartDateChange(event) {
        this.startDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.detail.value;
    }

    handleSubmit() {
        if (this.startDate && this.endDate && this.leaveType) {
            saveLeaveApplication({ startDate: this.startDate, endDate: this.endDate, leaveType: this.leaveType })
                .then(() => {
                    this.showToast('Success', 'Leave application submitted successfully', 'success');
                    
                    this.clearFields();

                    return refreshApex(this.wiredLeaveApplicationsResult);
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to submit leave application', 'error');
                });
        } else {
            this.showToast('Error', 'Please fill in all required fields', 'error');
        }
    }

    fetchVacationBalance() {
        getVacationBalance()
            .then(result => {
                this.vacationBalance = result;
            })
            .catch(error => {
                this.showToast('Error', 'Failed to fetch vacation balance', 'error');
            });
    }

    clearFields() {
        this.leaveType = '';
        this.startDate = '';
        this.endDate = '';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
