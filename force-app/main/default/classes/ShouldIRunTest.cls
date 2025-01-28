@isTest
public class ShouldIRunTest {
    @isTest
    public static void testStopTrigger() {
        // Test that stopTrigger() sets the allow variable to false
        shouldIRun.stopTrigger();
        System.assertEquals(false, shouldIRun.allow);
    }
    
    @isTest
    public static void testCanIRun() {
        // Test that canIRun() returns the correct value when allow is true
        shouldIRun.allow = true;
        System.assertEquals(true, shouldIRun.canIRun());
        
        // Test that canIRun() returns the correct value when allow is false
        shouldIRun.allow = false;
        System.assertEquals(false, shouldIRun.canIRun());
    }
}