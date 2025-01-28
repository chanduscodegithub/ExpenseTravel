({
    doinit: function (component, event, helper) {
        let strURL = window.location.href;
        let locURL = strURL.split('CRMITCommunity/s/');
        let backtoListTimesheet = locURL[0] + 'CRMITCommunity/s/applyleave';
        window.open(backtoListTimesheet, "_self");
    }
})