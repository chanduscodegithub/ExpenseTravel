export default function postProcessing(...args) {
    return new Promise((resolve, reject) => {
        args[1].forEach((value, key) => {
            if (value.length > 1) {
                const commonAllocation = [];
                args[0] = args[0].filter(eachAlloc => {
                    if (value.includes(eachAlloc.key)) {
                        commonAllocation.push(eachAlloc);
                        return false;
                    }
                    return true;
                })
                args[0].push(foundSameWeekAllocations(...commonAllocation));
            }
        })
        resolve(args[0]);
    })
}

function foundSameWeekAllocations(...args) {
    args.sort((curr, prev) => {
        return new Date(curr.eachProject[curr.eachProject.length - 1].eachDate.taStart) - new Date(prev.eachProject[prev.eachProject.length - 1].eachDate.taStart);
    })
    let combinedObj = args[0];
    combinedObj.groupedAllocation = true;
    combinedObj.groupedAllocationDates = [];
    args.forEach((eachAlloc, idx, orArr) => {
        combinedObj.groupedAllocationDates.push({
            allocId: eachAlloc.eachProject[0].eachDate.projectAllocId, startTA: eachAlloc.eachProject[0].eachDate.taStart, endTA: eachAlloc.eachProject[0].eachDate.taEnd,
            additionalData: {
                project: eachAlloc.eachProject[0].eachDate.project,
                projectId: eachAlloc.eachProject[0].eachDate.projectId,
                billingStatus: eachAlloc.eachProject[0].eachDate.billingStatus,
                allocPercentage: eachAlloc.eachProject[0].eachDate.allocPercentage,
                catOptions: eachAlloc.eachProject[0].eachDate.catOptions,
                subcatOptions: eachAlloc.eachProject[0].eachDate.subcatOptions
            }
        });
        eachAlloc.eachProject.forEach(eachTS => {
            eachTS.eachDate.taStart = orArr[0].eachProject[0].eachDate.taStart;
            eachTS.eachDate.taEnd = orArr[orArr.length - 1].eachProject[0].eachDate.taEnd;
        });
        if (idx != 0) {
            if (combinedObj.allocCent != eachAlloc.allocCent) {
                combinedObj.allocCent += `/${eachAlloc.allocCent}`;
            }
            if (combinedObj.status != eachAlloc.status) {
                combinedObj.status += `/${eachAlloc.status}`;
            }
            eachAlloc.eachProject.forEach(eachTS => {
                if (eachTS.eachDate.tsId !== undefined && eachTS.eachDate.tsId !== null) {
                    combinedObj.eachProject.push(eachTS);
                }
            });
        }
    })
    return combinedObj;
}