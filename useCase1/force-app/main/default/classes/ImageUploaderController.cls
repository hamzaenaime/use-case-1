public with sharing class ImageUploaderController {
  @AuraEnabled
  public static ContentVersion saveFile(
    Id recordId,
    String strFileName,
    String base64Data
  ) {
    base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
    ContentVersion cv = new ContentVersion();
    cv.Title = strFileName;
    cv.PathOnClient = '/' + strFileName;
    cv.FirstPublishLocationId = recordId;
    cv.VersionData = EncodingUtil.base64Decode(base64Data);
    cv.IsMajorVersion = true;
    SObjectAccessDecision decision = Security.stripInaccessible(
      AccessType.CREATABLE,
      new List<ContentVersion>{ cv }
    );
    insert decision.getRecords();
    return (ContentVersion) decision.getRecords().get(0);
  }
  @AuraEnabled
  public static String getImageUrl(Id recordId) {
    list<id> lstConDocs = new List<id>();
    for (ContentDocumentLink cntLink : [
      SELECT Id, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :recordId
      WITH SECURITY_ENFORCED
    ]) {
      lstConDocs.add(cntLink.ContentDocumentId);
    }
    if (!lstConDocs.isEmpty()) {
      Id contentVersionId = [
        SELECT Id, Title, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :lstConDocs
        LIMIT 1
      ]
      .Id;
      ContentDistribution cdl = [
        SELECT Id
        FROM ContentDistribution
        WHERE ContentVersionId = :contentVersionId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      return [
        SELECT DistributionPublicUrl, ContentDownloadUrl
        FROM ContentDistribution
        WHERE Id = :cdl.Id
        LIMIT 1
      ]
      .ContentDownloadUrl;
    } else {
      return null;
    }
  }

  @AuraEnabled
  public static String setImageUrl(Id recordId) {
    list<id> lstConDocs = new List<id>();
    for (ContentDocumentLink cntLink : [
      SELECT Id, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :recordId
      WITH SECURITY_ENFORCED
    ]) {
      lstConDocs.add(cntLink.ContentDocumentId);
    }
    if (!lstConDocs.isEmpty()) {
      ContentDistribution cdl = new ContentDistribution();
      cdl.ContentVersionId = [
        SELECT Id, Title, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :lstConDocs
        LIMIT 1
      ]
      .Id;
      cdl.Name = 'PublicShare';
      SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.CREATABLE,
        new List<ContentDistribution>{ cdl }
      );
      insert decision.getRecords();
      Id cdtId = decision.getRecords().get(0).Id;
      return [
        SELECT DistributionPublicUrl, ContentDownloadUrl
        FROM ContentDistribution
        WHERE Id = :cdtId
        LIMIT 1
      ]
      .ContentDownloadUrl;
    } else {
      return null;
    }
  }

  @AuraEnabled
  public static void deleteFiles(Id recordId) {
    list<id> lstConDocs = new List<id>();
    for (ContentDocumentLink cntLink : [
      SELECT Id, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :recordId
      WITH SECURITY_ENFORCED
    ]) {
      lstConDocs.add(cntLink.ContentDocumentId);
    }
    if (!lstConDocs.isEmpty()) {
      delete [SELECT Id FROM ContentDocument WHERE id IN :lstConDocs];
    }
  }
}
