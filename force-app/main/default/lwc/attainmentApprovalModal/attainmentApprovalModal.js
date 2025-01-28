import { LightningElement, wire } from 'lwc';
import getFinancialYears from '@salesforce/apex/QuotaTargetController.getFinancialYears';
import getRegions from '@salesforce/apex/QuotaTargetController.getRegions';
import getCategories from '@salesforce/apex/QuotaTargetController.getCategories';
import getQuotaTargets from '@salesforce/apex/QuotaTargetController.getQuotaTargets';

export default class QuotaTargetFilter extends LightningElement {
    selectedFinancialYear;
    selectedRegions = [];
    selectedCategories = [];
    financialYearOptions = [];
    regionOptions = [];
    categoryOptions = [];

    @wire(getFinancialYears)
    wiredFinancialYears({ error, data }) {
        if (data) {
            this.financialYearOptions = data.map(year => ({ label: year, value: year }));
        } else if (error) {
            console.error('Error fetching financial years:', error);
        }
    }

    @wire(getRegions)
    wiredRegions({ error, data }) {
        if (data) {
            this.regionOptions = data.map(region => ({ label: region, value: region }));
        } else if (error) {
            console.error('Error fetching regions:', error);
        }
    }

    @wire(getCategories)
    wiredCategories({ error, data }) {
        if (data) {
            this.categoryOptions = data.map(category => ({ label: category, value: category }));
        } else if (error) {
            console.error('Error fetching categories:', error);
        }
    }

    handleFilterChange() {
        const filterChangeEvent = new CustomEvent('filterchange', {
            detail: {
                financialYear: this.selectedFinancialYear,
                regions: this.selectedRegions,
                categories: this.selectedCategories
            }
        });
        this.dispatchEvent(filterChangeEvent);
    }

    handleFinancialYearChange(event) {
        this.selectedFinancialYear = event.detail.value;
        this.handleFilterChange();
    }

    handleRegionChange(event) {
        this.selectedRegions = event.detail.value;
        this.handleFilterChange();
    }

    handleCategoryChange(event) {
        this.selectedCategories = event.detail.value;
        this.handleFilterChange();
    }
}