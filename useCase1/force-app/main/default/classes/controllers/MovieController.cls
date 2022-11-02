public with sharing class MovieController {
  private static final Integer PAGE_SIZE = 6;
  private static final String SELECT_CLAUSE = 'SELECT id, name__c, category__c, description__c,Rating__c FROM Movie__c';
  @AuraEnabled
  public static void createMovie(Movie__c movie, List<Id> actorIds) {
    List<MovieActor__c> movieActors = new List<MovieActor__c>();
    try {
      insert movie;
      for (Id actorId : actorIds) {
        MovieActor__c movieActor = new MovieActor__c();
        movieActor.Actor__c = actorId;
        movieActor.Movie__c = movie.Id;
        movieActors.add(movieActor);
      }
      SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.CREATABLE,
        movieActors
      );
      insert decision.getRecords();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void updateMovie(Movie__c movie, List<Id> actorIds) {
    List<MovieActor__c> movieActors = new List<MovieActor__c>();
    List<MovieActor__c> deletedMovieActors = [
      SELECT Actor__c
      FROM MovieActor__c
      WHERE Movie__c = :movie.Id AND Actor__c NOT IN :actorIds
    ];
    try {
      delete deletedMovieActors;
      update movie;
      for (Id actorId : actorIds) {
        MovieActor__c movieActor = new MovieActor__c();
        movieActor.Actor__c = actorId;
        movieActor.Movie__c = movie.Id;
        movieActors.add(movieActor);
      }
      upsert movieActors;
      // SObjectAccessDecision decision = Security.stripInaccessible(
      //   AccessType.UPSERTABLE,
      //   movieActors
      // );
      // upsert decision.getRecords();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(Cacheable=true)
  public static MovieDTO getMovies(Integer pageNumber, String searchTerm) {
    Integer offset = PAGE_SIZE * (pageNumber - 1);
    String query = SELECT_CLAUSE;
    String movieNameQueryParam = '%' + searchTerm + '%';
    query += ' WHERE name__c like :movieNameQueryParam';
    query += ' ORDER BY CreatedDate DESC';
    query += ' LIMIT :PAGE_SIZE OFFSET :offset';
    try {
      MovieDTO result = new MovieDTO();
      result.totalItemCount = Database.countQuery(
        'SELECT count() FROM Movie__c WHERE name__c like :movieNameQueryParam'
      );
      result.pageSize = PAGE_SIZE;
      result.movies = Database.query(query);
      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void deleteMovie(Movie__c movie) {
    try {
      delete movie;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
