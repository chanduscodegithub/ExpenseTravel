import { LightningElement, track, wire, api } from 'lwc';
import getFinancialYears from '@salesforce/apex/FinancialPlanningController.getFinancialYears';
import getFinancialPlanningRecords from '@salesforce/apex/FinancialPlanningController.getFinancialPlanningRecords';
import getRevenueStreamRegions from '@salesforce/apex/FinancialPlanningController.getRevenueStreamRegions';
import getRevenueStreamEmployees from '@salesforce/apex/FinancialPlanningController.getRevenueStreamEmployees';

export default class FinancialPlanningForm extends LightningElement {
  @api record;
  @track yearOptions = [];
  @track selectedYear;
  @track showFinancialPlanningTab = false;
  @track financialPlanningTabLabel;
  @track financialPlanningRecords = [];
  @track showModal = false;
  @track modalHeader = '';
  @track modalData = [];
  @track Ctrlbgcolor;

  @wire(getFinancialYears)
  wiredFinancialYears({ error, data }) {
    if (data) {
      this.yearOptions = data.map(year => ({ label: year, value: year }));
      this.selectedYear = this.yearOptions[0].value;
      this.fetchFinancialPlanningRecords();
    } else if (error) {
      console.error('Error:', error);
    }
  }

  getAttainmentColor(attainment) {
    if (attainment >= 90) {
      return 'green-text';
    } else if (attainment >= 70) {
      return 'yellow-text';
    } else {
      return 'red-text';
    }
  }
  
  handleYearChange(event) {
    this.selectedYear = event.detail.value;
    this.fetchFinancialPlanningRecords();
  }

  getEmployeeAttainmentColor(attainment) {
    this.Ctrlbgcolor = (attainment < 90) ? 'bgClolor1' : 'bgClolor2';
  }



  fetchFinancialPlanningRecords() {
    getFinancialPlanningRecords({ year: this.selectedYear })
      .then(result => {
        this.financialPlanningRecords = result.map(record => {
          return {
            ...record,
            showFinancialPlanningTab: true,
            employeeDetails: [],
            regionDetails: []
          };
        });

        if (this.financialPlanningRecords.length === 0) {
          this.financialPlanningRecords.push({
            showFinancialPlanningTab: false,
            employeeDetails: [],
            regionDetails: []
          });
        } else {
          this.financialPlanningRecords.forEach(record => {
            this.createTabs(record);
          });
        }
      })
      .catch(error => {
        console.error('Error:', error);
      });
  }

  createTabs(record) {
    getRevenueStreamEmployees({ financialPlanningName: record.Name })
      .then(result => {
        record.employeeDetails = result;
      })
      .catch(error => {
        console.error('Error:', error);
      });

    getRevenueStreamRegions({ financialPlanningName: record.Name })
      .then(result => {
        record.regionDetails = result;
      })
      .catch(error => {
        console.error('Error:', error);
      });
  }

  loadEmployeeDetails(event) {
    const financialPlanningName = event.target.label;
    const record = this.financialPlanningRecords.find(
      record => record.Name === financialPlanningName
    );
    if (record) {
      if (record.employeeDetails.length === 0) {
        getRevenueStreamEmployees({ financialPlanningName })
          .then(result => {
            record.employeeDetails = result;
          })
          .catch(error => {
            console.error('Error:', error);
          });
      }
    }
  }

  loadRegionDetails(event) {
    const financialPlanningName = event.target.label;
    const record = this.financialPlanningRecords.find(
      record => record.Name === financialPlanningName
    );
    if (record) {
      if (record.regionDetails.length === 0) {
        getRevenueStreamRegions({ financialPlanningName })
          .then(result => {
            record.regionDetails = result;
          })
          .catch(error => {
            console.error('Error:', error);
          });
      }
    }
  }

 

  findEmployeeDetails(employeeId) {
    let details = null;
    this.financialPlanningRecords.forEach(record => {
      record.employeeDetails.forEach(employee => {
        if (employee.Id === employeeId) {
          details = employee;
        }
      });
    });
    return details;
  }



  handleRegionClick(event) {
    event.preventDefault();
    const regionId = event.currentTarget.dataset.id;
    const regionDetails = this.findRegionDetails(regionId);
    this.modalHeader = regionDetails.Name;
    this.modalData = [regionDetails];
    this.showModal = true;
  }

  findRegionDetails(regionId) {
    let details = null;
    this.financialPlanningRecords.forEach(record => {
      record.regionDetails.forEach(region => {
        if (region.Id === regionId) {
          details = region;
        }
      });
    });
    return details;
  }
}