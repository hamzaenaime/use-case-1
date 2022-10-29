public with sharing class ActorsController {
  @AuraEnabled(Cacheable=true)
  public static Actor__c[] getActors() {
    try {
      return [SELECT ID, NAME FROM Actor__c WITH SECURITY_ENFORCED];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
