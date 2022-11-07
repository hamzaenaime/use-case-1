@isTest
public class MovieControllerTest {
  @IsTest
  static void testCreateMovieRequiredFields() {
    Movie__c movie = new Movie__c();
    Boolean exceptionOccurred = false;
    Test.startTest();
    try {
      MovieController.createMovie(movie, new List<Id>());
    } catch (Exception e) {
      exceptionOccurred = true;
    }
    Test.stopTest();
    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }

  @IsTest
  static void testCreateMovieCategoryPickListValues() {
    Movie__c movie = new Movie__c(
      Name__c = 'Movie 1',
      Category__c = 'Category 1'
    );
    Boolean exceptionOccurred = false;
    Test.startTest();
    try {
      MovieController.createMovie(movie, new List<Id>());
    } catch (Exception e) {
      exceptionOccurred = true;
    }
    Test.stopTest();
    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }

  @IsTest
  static void testCreateMovieWithActors() {
    Movie__c movie = (Movie__c) TestDataFactory.createSObject(
      'Movie__c',
      false
    );
    Actor__c actor = (Actor__c) TestDataFactory.createSObject('Actor__c');
    List<Id> ids = new List<Id>{ actor.Id };
    Test.startTest();
    MovieController.createMovie(movie, ids);
    Test.stopTest();
    System.assert(
      [SELECT Name__c FROM Movie__c WHERE Name__c = :movie.Name__c].size() > 0,
      'Movie is not inserted'
    );
    System.assertEquals(
      movie.Name__c,
      [SELECT Name__c FROM Movie__c WHERE Name__c = :movie.Name__c]
      .Name__c,
      'A wrong movie has been inserted'
    );
    System.assert(
      [
        SELECT Movie__c, Actor__c
        FROM MovieActor__c
        WHERE Actor__c = :actor.Id
      ]
      .size() > 0,
      'No actor movie has been inserted'
    );
    System.assertEquals(
      actor.Id,
      [
        SELECT Movie__c, Actor__c
        FROM MovieActor__c
        WHERE Actor__c = :actor.Id
      ]
      .Actor__c,
      'A wrong actor movie has been inserted into MovieActor__c object'
    );
  }

  @IsTest
  static void testUpdateMovieRequiredFields() {
    Movie__c movie = new Movie__c();
    Boolean exceptionOccurred = false;
    Test.startTest();
    try {
      MovieController.updateMovie(movie, new List<Id>());
    } catch (Exception e) {
      exceptionOccurred = true;
    }
    Test.stopTest();
    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }

  @IsTest
  static void testUpdateMovieCategoryPickListValues() {
    Movie__c movie = new Movie__c(Name__c = 'Name', Category__c = 'Category');

    Boolean exceptionOccurred = false;
    Test.startTest();
    try {
      MovieController.updateMovie(movie, new List<Id>());
    } catch (Exception e) {
      exceptionOccurred = true;
    }
    Test.stopTest();
    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }

  @IsTest
  static void testUpdateMovieWithActors() {
    Movie__c movie = (Movie__c) TestDataFactory.createSObject('Movie__c');
    Actor__c actor = (Actor__c) TestDataFactory.createSObject('Actor__c');
    List<Id> ids = new List<Id>{ actor.Id };
    Test.startTest();
    movie.Name__c = 'name updated';
    movie.Category__c = 'Action';
    MovieController.updateMovie(movie, ids);
    Test.stopTest();
    List<Movie__c> movies = [
      SELECT Id, Name__c, Category__c
      FROM Movie__c
      WHERE Id = :movie.Id
    ];
    System.assertEquals(
      'name updated',
      movies[0].Name__c,
      'Movie name has not been updated'
    );
    System.assertEquals(
      'Action',
      movies[0].Category__c,
      'Movie category has not been updated'
    );
    List<MovieActor__c> movieActors = [
      SELECT Movie__c, Actor__c, key__c
      FROM MovieActor__c
      WHERE Actor__c = :actor.Id AND Movie__c = :movie.Id
    ];
    System.assert(
      movieActors.size() > 0,
      'No actor movie has been inserted into MovieActor__c object'
    );
    System.assertEquals(
      actor.Id,
      movieActors[0].Actor__c,
      'A wrong actor movie has been inserted into MovieActor__c object'
    );
    System.assertEquals(
      movie.Id,
      movieActors[0].Movie__c,
      'A wrong actor movie has been inserted into MovieActor__c object'
    );
    System.assertEquals(
      actor.Id +
      '' +
      movie.Id,
      movieActors[0].key__c,
      'A wrong actor movie has been inserted into MovieActor__c object'
    );
  }

  @IsTest
  static void testGetMovies() {
    TestDataFactory.createSObjectList('Movie__c', 50);
    Test.startTest();
    MovieDTO result = MovieController.getMovies(1, '');
    Test.stopTest();
    System.assertEquals(50, result.totalItemCount, 'Wrong total movies count');
    System.assertEquals(6, result.pageSize, 'Wrong page size');
    System.assertEquals(6, result.movies.size(), 'Get movies reutrn no result');
  }
  @IsTest
  static void testGetMoviesWithSearchTerm() {
    TestDataFactory.createSObjectList('Movie__c', 50);
    for (Integer i = 0; i < 5; i++) {
      TestDataFactory.createSObject(
        'Movie__c',
        new Map<String, Object>{ 'Name__c' => 'Movie ' + i }
      );
    }
    Test.startTest();
    MovieDTO result = MovieController.getMovies(1, 'Movie');
    Test.stopTest();
    System.assertEquals(5, result.totalItemCount, 'Wrong total movies count');
    System.assertEquals(6, result.pageSize, 'Wrong page size');
    System.assertEquals(5, result.movies.size(), 'Get movies reutrn no result');
  }

  @IsTest
  static void testDeleteMovie() {
    Movie__c movie = (Movie__c) TestDataFactory.createSObject('Movie__c');
    Id movieId = movie.Id;
    Test.startTest();
    MovieController.deleteMovie(movie);
    Test.stopTest();
    System.assertEquals(
      0,
      [SELECT Id FROM Movie__c WHERE Id = :movieId].size(),
      'Movie has not been deleted'
    );
    System.assertEquals(
      0,
      [SELECT Movie__c FROM MovieActor__c WHERE Movie__c = :movieId].size(),
      'MovieActor has not been deleted'
    );
  }
  @IsTest
  static void testDeleteMovieDoesntExist() {
    Movie__c movie = (Movie__c) TestDataFactory.createSObject(
      'Movie__c',
      false
    );
    Boolean exceptionOccurred = false;
    Test.startTest();
    try {
      MovieController.deleteMovie(movie);
    } catch (Exception e) {
      exceptionOccurred = true;
    }
    Test.stopTest();
    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }
}
