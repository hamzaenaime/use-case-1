public with sharing class ImageUploadController {
  @AuraEnabled
  public static string saveImage(String documentId) {
    try {
      ContentVersion cv = [
        SELECT id
        FROM contentversion
        WHERE contentdocumentid = :documentId
      ];
      ContentDistribution cd = new ContentDistribution();
      cd.Name = 'Test';
      cd.ContentVersionId = cv.id;
      cd.PreferencesAllowViewInBrowser = true;
      cd.PreferencesLinkLatestVersion = true;
      cd.PreferencesNotifyOnVisit = false;
      cd.PreferencesPasswordRequired = false;
      cd.PreferencesAllowOriginalDownload = true;
      insert cd;
      return [
        SELECT ContentDownloadUrl
        FROM ContentDistribution
        WHERE ContentDocumentId = :documentId
        LIMIT 1
      ]
      .ContentDownloadUrl;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
