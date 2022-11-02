public with sharing class ActorsController {
  @AuraEnabled(Cacheable=true)
  public static Actor__c[] getActors() {
    try {
      SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.READABLE,
        [SELECT ID, NAME FROM Actor__c WITH SECURITY_ENFORCED]
      );
      return decision.getRecords();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<MovieActor__c> getActorsByMovieId(Id movieId) {
    try {
      SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.READABLE,
        [
          SELECT Actor__r.Name
          FROM MovieActor__c
          WHERE Movie__c = :movieId
        ]
      );
      return decision.getRecords();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
