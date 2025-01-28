public class helperForAccount {
    public static Note createNoteByName(String Name, Id parent_Id){
        Note n = new Note();
        n.Title = Name;
        n.ParentId = parent_Id;
        return n;
    }
    
    public static ContentNote createContentNote(String Name, String Descr){
        ContentNote cn = new ContentNote();
        cn.Title = Name;
        String body = Descr;
        cn.Content = Blob.valueOf(body.escapeHTML4());
        return cn;
    }
    
    public static ContentDocumentLink createContentDocumentLink(Id contentNoteId, Id AccountId){
        ContentDocumentLink link2 = new ContentDocumentLink();
        link2.ContentDocumentId = contentNoteId;
        link2.LinkedEntityId = AccountId;
        link2.ShareType = 'V';
        link2.Visibility = 'AllUsers';
        return link2;
    }
}