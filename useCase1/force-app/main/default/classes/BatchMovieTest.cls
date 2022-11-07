@isTest
public class BatchMovieTest {
  @IsTest
  private static void testMovieBatch() {
    TestDataFactory.createSObjectList(
      'Movie__c',
      new Map<String, Object>{
        'IsReleased__c' => false,
        'Release_date__c' => System.today()
      },
      200,
      true
    );

    Test.startTest();
    MovieBatch movieBatch = new MovieBatch();
    Database.executeBatch(movieBatch);
    Test.stopTest();
    List<Movie__c> movies = [SELECT IsReleased__c FROM Movie__c];
    System.assertEquals(
      true,
      movies[0].IsReleased__c,
      'isReleased value is not correct'
    );
  }
}
