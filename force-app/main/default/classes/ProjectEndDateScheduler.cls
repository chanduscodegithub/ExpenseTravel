public class ProjectEndDateScheduler {

    public static void scheduleJob() {
        String cronExpression = '0 31 12 * * ?';
        ProjectEndDateNotifier extensionDateJob = new ProjectEndDateNotifier();
        System.schedule('Project Extension Date Reminder', cronExpression, extensionDateJob);

        ProjectOnboardingNotifier onboardingJob = new ProjectOnboardingNotifier();
        System.schedule('Project Onboarding Alert', cronExpression, onboardingJob);

        ProjectOffboardingNotifier offboardingJob = new ProjectOffboardingNotifier();
        System.schedule('Project Offboarding Alert', cronExpression, offboardingJob);

        CheckContractAgreementUploaded contractAgreement=new CheckContractAgreementUploaded();
        System.schedule('Project Check Contract is Uploaded', cronExpression, contractAgreement);
    }

    public static void abortAllJobs() {
        List<CronTrigger> cronTriggers = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Project%' OR CronJobDetail.Name LIKE 'Check%'];
        for (CronTrigger ct : cronTriggers) {
            try {
                System.abortJob(ct.Id);
                System.debug('Aborted job: ' + ct.CronJobDetail.Name);
            } catch (Exception e) {
                System.debug('Failed to abort job: ' + ct.CronJobDetail.Name + ' with error: ' + e.getMessage());
            }
        }
    }

}