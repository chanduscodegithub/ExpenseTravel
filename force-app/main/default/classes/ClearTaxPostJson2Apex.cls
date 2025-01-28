public class ClearTaxPostJson2Apex {

	public UserInputArgs userInputArgs;
	public FileInfo fileInfo;

	public class Gstins {
	}

	public class FileInfo {
		public String s3FileUrl;
		public String userFileName;
	}

	public class UserInputArgs {
		public List<Gstins> gstins;
		public String templateId;
	}

	
	/*public static ClearTaxPostJson2Apex parse(String json) {
		return (ClearTaxPostJson2Apex) System.JSON.deserialize(json, ClearTaxPostJson2Apex.class);
	}*/
}