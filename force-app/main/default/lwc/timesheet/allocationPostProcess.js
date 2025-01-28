export default function handleAllocation(generatedObj) {
    return new Promise((resolve, reject) => {
        generatedObj.forEach(eachAlloc => {
            if (eachAlloc.groupedAllocation) {
                eachAlloc.eachProject = rearrangeAlloc(eachAlloc.eachProject, eachAlloc.groupedAllocationDates);
            }
        })
        resolve(generatedObj);
    });
}
function rearrangeAlloc(...args) {
    args[0].forEach(eachTS => {
        let selectedDate = window.moment(eachTS.eachDate.date);
        args[1].forEach(eachAccAlloc => {
            let taStartMoment = window.moment(eachAccAlloc.startTA);
            let taEndMoment = window.moment(eachAccAlloc.endTA);
            if ((selectedDate.isAfter(taStartMoment) && taEndMoment.isAfter(selectedDate)) || taEndMoment.isSame(selectedDate, 'day') || taStartMoment.isSame(selectedDate, 'day')) {
                eachTS.eachDate.projectAllocId = eachAccAlloc.allocId
            }
        });
    });
    return args[0];
}