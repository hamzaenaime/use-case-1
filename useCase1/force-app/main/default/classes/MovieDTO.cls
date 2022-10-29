public with sharing class MovieDTO {
  @AuraEnabled
  public Integer pageSize { get; set; }

  @AuraEnabled
  public Integer pageNumber { get; set; }

  @AuraEnabled
  public Integer totalItemCount { get; set; }

  @AuraEnabled
  public Movie__c[] movies { get; set; }
}
