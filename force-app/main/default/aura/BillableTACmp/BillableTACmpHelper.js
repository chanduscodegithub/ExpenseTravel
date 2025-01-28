({
    renderPage : function(component) {
        var records =component.get("v.billableTAList");
        // console.log("============="+records);
        var pNumber=component.get("v.pageNumber");
        // console.log("0000000000000"+pNumber);
        var pRecords=records.slice((pNumber-1)*component.get('v.pagesize'),pNumber*component.get('v.pagesize'));
        // console.log("+++===============++++"+pRecords);
        component.set("v.currentBillableTAList",pRecords);
        console.log(pRecords);
    }
})