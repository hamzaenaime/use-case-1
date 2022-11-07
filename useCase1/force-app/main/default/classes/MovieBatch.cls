global class MovieBatch implements Database.Batchable<sObject>, Schedulable {
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, Release_date__c, IsReleased__c
        FROM Movie__c
      ]
    );
  }
  global void execute(Database.BatchableContext bc, List<Movie__c> movies) {
    Date today = System.today();
    for (Movie__c movie : movies) {
      if (movie.Release_date__c >= today) {
        movie.IsReleased__c = true;
      }
    }
    update movies;
  }
  global void finish(Database.BatchableContext bc) {
    System.debug('Batch done!');
  }
  global void execute(SchedulableContext sc) {
    MovieBatch movieBatch = new MovieBatch();
    Database.executeBatch(movieBatch);
  }
}
