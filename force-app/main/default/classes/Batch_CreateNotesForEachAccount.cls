/*********************************************************************************************/ 
/* Class Name: Batch_CreateNotesForEachAccount */
/* Purpose: This is the Batch class to process Accounts and create Notes to it.
/*********************************************************************************************/
global class Batch_CreateNotesForEachAccount implements DataBase.Batchable<sObject>,DataBase.StateFul{
    global List<String> exception_List = new List<String>();
    global List<String> success_List = new List<String>();
    Set<Id> failIds = new Set<Id>();
    Set<Id> successIds = new Set<Id>();
    Integer successCount = 0;
    Integer failureCount = 0;
    Integer totalNoteProcessed = 0;
    
    public Batch_CreateNotesForEachAccount()
    {
        /*String noteTitle1 = 'Note 1';
        String noteTitle2 = 'Note 2';
        String noteTitle3 = 'Note 3';
        String descr1 = '';
        String descr2 = '';
        String descr3 = '';
        ContentNotesList.add(helperForAccount.createContentNote(noteTitle1,descr1));
        ContentNotesList.add(helperForAccount.createContentNote(noteTitle2,descr2));
        ContentNotesList.add(helperForAccount.createContentNote(noteTitle3,descr3));
        Insert ContentNotesList;
        
        if(ContentNotesList!=null && ContentNotesList.size()>0){
            for(ContentNote c:ContentNotesList){
                setContentNoteIds.add(c.id);
            }
        }
        System.debug('Inserted ids: '+setContentNoteIds);*/
    }
    /****************************************************************************************************** 
*   This method will initialize the list of delivery items to be processed.
******************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id FROM Account ]);
    }
    
    
    /****************************************************************************************************** 
*   This method will process list of Accounts and create the Notes for it
******************************************************************************************************/
    global void execute(Database.BatchableContext bat, List<sObject> scope){
        List<Account> accountList = new List<Account>();
        List<Note> notesList = new List<Note>();
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
        List<ContentNote> ContentNotesList = new List<ContentNote>();
        Set<Id> setContentNoteIds = new Set<Id>();
        
        if(scope != null){
            accountList = scope;
        }
       String noteTitle1 = 'Current IT / CRM landscape';
        String noteTitle2 = 'Market Research / Insights';
        String noteTitle3 = 'Present partners / Vendors & their Role';
        String descr1 = '';
        String descr2 = '';
        String descr3 = '';
        ContentNotesList.add(helperForAccount.createContentNote(noteTitle1,descr1));
        ContentNotesList.add(helperForAccount.createContentNote(noteTitle2,descr2));
        ContentNotesList.add(helperForAccount.createContentNote(noteTitle3,descr3));
        Insert ContentNotesList;
        
        if(ContentNotesList!=null && ContentNotesList.size()>0){
            for(ContentNote c:ContentNotesList){
                setContentNoteIds.add(c.id);
            }
        }
        System.debug('Inserted ids: '+setContentNoteIds);
        for(Account acc: accountList){
            for(Id conId : setContentNoteIds ){
                ContentDocumentLinkList.add(helperForAccount.createContentDocumentLink(conId,acc.Id));
            }
        }
        
        Database.SaveResult[] sr = Database.insert(ContentDocumentLinkList,false);
        for(integer i =0; i<ContentDocumentLinkList.size();i++)
        {
            String msg1='';
            String msg2='';
            If(!sr[i].isSuccess())
            {
                failIds.add(ContentDocumentLinkList.get(i).id);
                msg1 += ContentDocumentLinkList.get(i).id + '==>'+'Error: "';        
                for(Database.Error err: sr[i].getErrors()){  
                    msg1 += err.getmessage()+'\n';
                    
                }
                failureCount++; 
            }else
            {
                successIds.add(ContentDocumentLinkList.get(i).id);
                successCount++;
                msg2= msg2+''+ ContentDocumentLinkList.get(i).id +'==>'+'SUCCESS: Created!';
                
                
            }
            if(msg1!='')
                exception_List.add(msg1);
            if(msg2!='')
                success_List.add(msg2);
            totalNoteProcessed++;
        }
    }
    
    /****************************************************************************************************** 
*   This method will notify the Admin on the status of batch and log the result of the batch of 
*   Accounts processed.
******************************************************************************************************/
    global void finish(Database.BatchableContext bc) {
        
        System.debug('');
        System.debug('successCount: '+successCount);
        System.debug('exception_List: '+exception_List);
        System.debug('success_List: '+success_List);
        System.debug('totalNoteProcessed: '+totalNoteProcessed);
    }
}