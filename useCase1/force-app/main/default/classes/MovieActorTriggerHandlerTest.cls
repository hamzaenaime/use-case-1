@isTest
public class MovieActorTriggerHandlerTest {
  @IsTest
  static void testCalculateGenderPercentage() {
    Actor__c maleActor = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Gender__c' => 'Male' }
    );
    Actor__c femaleActor = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Gender__c' => 'Female' }
    );
    Movie__c movie = (Movie__c) TestDataFactory.createSobject('Movie__c');
    Test.startTest();
    MovieController.updateMovie(
      movie,
      new List<Id>{ maleActor.Id, femaleActor.Id }
    );
    Test.stopTest();
    System.assertEquals(
      50,
      [
        SELECT Id, FemaleActorsPercentage__c
        FROM Movie__c
        WHERE Id = :movie.Id
        LIMIT 1
      ]
      .FemaleActorsPercentage__c,
      'Wrong gender percentage'
    );
    System.assertEquals(
      50,
      [
        SELECT Id, MaleActorsPercentage__c
        FROM Movie__c
        WHERE Id = :movie.Id
        LIMIT 1
      ]
      .MaleActorsPercentage__c,
      'Wrong gender percentage'
    );
  }
  @IsTest
  static void testCalculatePercentageOnlyMale() {
    Actor__c maleActor1 = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Gender__c' => 'Male' }
    );
    Actor__c maleActor2 = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Gender__c' => 'Male' }
    );
    Movie__c movie = (Movie__c) TestDataFactory.createSobject('Movie__c');
    Test.startTest();
    MovieController.updateMovie(
      movie,
      new List<Id>{ maleActor1.Id, maleActor2.Id }
    );
    Test.stopTest();
    System.assertEquals(
      0,
      [
        SELECT Id, FemaleActorsPercentage__c
        FROM Movie__c
        WHERE Id = :movie.Id
        LIMIT 1
      ]
      .FemaleActorsPercentage__c,
      'Wrong gender percentage'
    );
    System.assertEquals(
      100,
      [
        SELECT Id, MaleActorsPercentage__c
        FROM Movie__c
        WHERE Id = :movie.Id
        LIMIT 1
      ]
      .MaleActorsPercentage__c,
      'Wrong gender percentage'
    );
  }

  @IsTest
  static void testCalculateGenderPercentageAfterDelete() {
    Actor__c maleActor1 = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Gender__c' => 'Male' }
    );
    Actor__c maleActor2 = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Gender__c' => 'Male' }
    );
    Actor__c maleActor3 = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Gender__c' => 'Male' }
    );
    Actor__c femaleActor = (Actor__c) TestDataFactory.createSobject(
      'Actor__c',
      new Map<String, Object>{ 'Gender__c' => 'Female' }
    );
    Movie__c movie = (Movie__c) TestDataFactory.createSobject('Movie__c');
    MovieActor__c movieActor1 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{
        'Actor__c' => maleActor1.Id,
        'Movie__c' => movie.Id
      }
    );
    MovieActor__c movieActor2 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{
        'Actor__c' => maleActor2.Id,
        'Movie__c' => movie.Id
      }
    );
    MovieActor__c movieActor3 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{
        'Actor__c' => maleActor3.Id,
        'Movie__c' => movie.Id
      }
    );
    MovieActor__c movieActor4 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{
        'Actor__c' => femaleActor.Id,
        'Movie__c' => movie.Id
      }
    );
    Test.startTest();
    delete movieActor3; //delete one male movieactor
    Test.stopTest();
    System.assertEquals(
      33,
      [
        SELECT Id, FemaleActorsPercentage__c
        FROM Movie__c
        WHERE Id = :movie.Id
        LIMIT 1
      ]
      .FemaleActorsPercentage__c,
      'Wrong gender percentage'
    );
    System.assertEquals(
      66,
      [
        SELECT Id, MaleActorsPercentage__c
        FROM Movie__c
        WHERE Id = :movie.Id
        LIMIT 1
      ]
      .MaleActorsPercentage__c,
      'Wrong gender percentage'
    );
  }

  @IsTest
  static void testCalculateNumberOfMoviesOfActor() {
    Test.startTest();
    Actor__c actor = (Actor__c) TestDataFactory.createSobject('Actor__c');
    Movie__c movie1 = (Movie__c) TestDataFactory.createSobject('Movie__c');
    Movie__c movie2 = (Movie__c) TestDataFactory.createSobject('Movie__c');
    Movie__c movie3 = (Movie__c) TestDataFactory.createSobject('Movie__c');
    MovieActor__c movieActor1 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{ 'Actor__c' => actor.Id, 'Movie__c' => movie1.Id }
    );
    MovieActor__c movieActor2 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{ 'Actor__c' => actor.Id, 'Movie__c' => movie2.Id }
    );
    MovieActor__c movieActor3 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{ 'Actor__c' => actor.Id, 'Movie__c' => movie3.Id }
    );
    Test.stopTest();

    System.assertEquals(
      3,
      [
        SELECT Id, Number_of_movies__c
        FROM Actor__c
        WHERE Id = :actor.Id
        LIMIT 1
      ]
      .Number_of_movies__c,
      'Wrong number of movies'
    );
  }
  @isTest
  static void testCalculateNumberOfMoviesOfActorAfterDelete() {
    Test.startTest();
    Actor__c actor = (Actor__c) TestDataFactory.createSobject('Actor__c');
    Movie__c movie1 = (Movie__c) TestDataFactory.createSobject('Movie__c');
    Movie__c movie2 = (Movie__c) TestDataFactory.createSobject('Movie__c');
    Movie__c movie3 = (Movie__c) TestDataFactory.createSobject('Movie__c');
    MovieActor__c movieActor1 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{ 'Actor__c' => actor.Id, 'Movie__c' => movie1.Id }
    );
    MovieActor__c movieActor2 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{ 'Actor__c' => actor.Id, 'Movie__c' => movie2.Id }
    );
    MovieActor__c movieActor3 = (MovieActor__c) TestDataFactory.createSobject(
      'MovieActor__c',
      new Map<String, Object>{ 'Actor__c' => actor.Id, 'Movie__c' => movie3.Id }
    );
    delete movieActor2;
    Test.stopTest();

    System.assertEquals(
      2,
      [
        SELECT Id, Number_of_movies__c
        FROM Actor__c
        WHERE Id = :actor.Id
        LIMIT 1
      ]
      .Number_of_movies__c,
      'Wrong number of movies'
    );
  }
}
