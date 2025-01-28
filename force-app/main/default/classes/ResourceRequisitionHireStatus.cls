public class ResourceRequisitionHireStatus {

    // Method to update the Position status and joining date based on the highest Job Application status and latest updated date
    public static void updatePositionStatus(Set<Id> positionIds) {
        if (positionIds == null || positionIds.isEmpty()) {
            System.debug('No Position Ids provided.');
            return;
        }

        // Query related Job Application records for these positions, including LastModifiedDate and Joining_Date__c
        List<Job_Application__c> jobApplications = [
            SELECT Id, Picklist__c, Position__c, Date_Of_Joining__c, LastModifiedDate 
            FROM Job_Application__c 
            WHERE Position__c IN :positionIds
        ];

        if (jobApplications.isEmpty()) {
            System.debug('No Job Application records found for provided Position Ids.');
            return;
        }

        // Priority map for ranking statuses
        Map<String, Integer> priorityMap = new Map<String, Integer>{
            'Rejected' => 0, 
            'Offer Declined' => 1, 
            'No Show' => 2, 
            'On Hold' => 3, 
            'Talent Identified' => 4, 
            'Interview Schedule' => 5, 
            'Interview No Show' => 6,
            'Interview In Progress' => 7,
            'Leadership Connects' => 8,
            'Feedback Awaited' => 9,
            'Selected' => 10,
            'HR Review In Progress' => 11, 
            'Documents Verified' => 12,
            'Offer Extended' => 13,
            'Offer Accepted' => 14,
            'Joined/Onboarded' => 15
        };

        // Store highest priority and latest joining date for each Position
        Map<Id, Integer> highestPriorityByPosition = new Map<Id, Integer>();
        Map<Id, Date> latestJoiningDateByPosition = new Map<Id, Date>();
        Map<Id, DateTime> latestModifiedDateByPosition = new Map<Id, DateTime>();

        // Iterate through job applications to determine highest priority status and latest joining date
        for (Job_Application__c jobApp : jobApplications) {
            Integer currentPriority = priorityMap.get(jobApp.Picklist__c);

            // Track highest priority for each position
            if (currentPriority != null) {
                if (!highestPriorityByPosition.containsKey(jobApp.Position__c) || 
                    highestPriorityByPosition.get(jobApp.Position__c) < currentPriority) {
                    highestPriorityByPosition.put(jobApp.Position__c, currentPriority);
                }
            }

            // Track latest joining date based on LastModifiedDate
            if (jobApp.Date_Of_Joining__c != null) {
                if (!latestModifiedDateByPosition.containsKey(jobApp.Position__c) || 
                    latestModifiedDateByPosition.get(jobApp.Position__c) < jobApp.LastModifiedDate) {
                    latestJoiningDateByPosition.put(jobApp.Position__c, jobApp.Date_Of_Joining__c);
                    latestModifiedDateByPosition.put(jobApp.Position__c, jobApp.LastModifiedDate);
                }
            }
        }

        // Map to translate priority values to Position Status values
        Map<Integer, String> statusMap = new Map<Integer, String>{
            0 => 'Talent Identified',
            1 => 'Talent Identified',
            2 => 'Talent Identified',
            3 => 'Talent Identified',
            4 => 'Talent Identified',
            5 => 'Interviews in progress',
            6 => 'Interviews in progress',
            7 => 'Interviews in progress',
            8 => 'Leadership Connects',
            9 => 'Interviews in progress',
            10 => 'Interviews in progress',
            11 => 'HR Evaluation',
            12 => 'HR Evaluation',
            13 => 'Offer Closure',
            14 => 'Joining Awaited',
            15 => 'Joined/Onboarded'
        };

        // Query Position records in bulk (to avoid SOQL queries in loops)
        Map<Id, Position__c> positionMap = new Map<Id, Position__c>([
            SELECT Id, Status__c, Hire_By__c FROM Position__c WHERE Id IN :positionIds
        ]);

        List<Position__c> positionsToUpdate = new List<Position__c>();

        // Iterate through the position records and update the status and Hire_By__c
        for (Id positionId : positionMap.keySet()) {
            Position__c position = positionMap.get(positionId);
            Integer highestPriority = highestPriorityByPosition.get(positionId);

            if (highestPriority != null && statusMap.containsKey(highestPriority)) {
                position.Status__c = statusMap.get(highestPriority);
            }

            // Update Hire_By__c with the latest Joining Date
            if (latestJoiningDateByPosition.containsKey(positionId)) {
                Date latestJoiningDate = latestJoiningDateByPosition.get(positionId);
                position.Hire_By__c = latestJoiningDate;
            }

            positionsToUpdate.add(position);
        }

        // Bulk update Position records
        if (!positionsToUpdate.isEmpty()) {
            update positionsToUpdate;
            System.debug('Updated Positions: ' + positionsToUpdate);
        } else {
            System.debug('No Positions to update.');
        }
    }
}