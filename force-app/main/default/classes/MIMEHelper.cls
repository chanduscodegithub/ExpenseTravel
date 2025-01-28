public class MIMEHelper {
    public static String getMIMEType(String fileType) {
        String mimeType = 'application/octet-stream'; // Default MIME type

        if (fileType != null) {
            fileType = fileType.toLowerCase();
              //CSV, EXCEL, LINK, PDF, PNG, TEXT, WORD, ZIP, UNKNOWN.
            // Add additional mappings for file extensions and MIME types as needed
            if (fileType == 'pdf') {
                mimeType = 'application/pdf';
            } else if (fileType == 'jpg' || fileType == 'jpeg') {
                mimeType = 'image/jpeg';
            } else if (fileType == 'png') {
                mimeType = 'image/png';
            } else if (fileType == 'text') {
                mimeType = 'text/plain';
            } else if (fileType == 'WORD' || fileType == 'docx' || fileType == 'doc') {
                mimeType = 'application/msword';
            } else if (fileType == 'csv') {
                mimeType = 'text/csv';
            } else if (fileType == 'ppt' || fileType == 'pptx' || fileType == 'POWER_POINT_X') {
                mimeType = 'application/vnd.ms-powerpoint';
            } else if (fileType =='EXCEL'){
                mimeType = 'application/vnd.ms-excel';
            }
        }

        return mimeType;
    }
}