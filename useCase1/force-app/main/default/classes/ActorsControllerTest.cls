@isTest
public class ActorsControllerTest {
  @IsTest
  static void testGetActors() {
    Test.startTest();
    List<Actor__c> actors = (List<Actor__c>) TestDataFactory.createSobjectList(
      'Actor__c',
      10
    );
    Test.stopTest();
    System.assertEquals(
      10,
      ActorsController.getActors().size(),
      'Wrong actors count'
    );
  }

  @IsTest
  static void testGetActorsById() {
    Test.startTest();
    Movie__c movie = (Movie__c) TestDataFactory.createSobject('Movie__c');
    Actor__c actor1 = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Name' => 'Actor 1' }
    );
    Actor__c actor2 = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Name' => 'Actor 2' }
    );
    MovieActor__c movieActor1 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{ 'Actor__c' => actor1.Id, 'Movie__c' => movie.Id }
    );
    MovieActor__c movieActor2 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{ 'Actor__c' => actor2.Id, 'Movie__c' => movie.Id }
    );
    Test.stopTest();
    System.assertEquals(
      2,
      ActorsController.getActorNamesByMovieId(movie.Id).size(),
      'Wrong actors count'
    );
    System.assertEquals(
      'Actor 1',
      ActorsController.getActorNamesByMovieId(movie.Id)[0].Actor__r.Name,
      'Wrong actor name'
    );
  }
}
