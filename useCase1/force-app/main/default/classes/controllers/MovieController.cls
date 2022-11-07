public with sharing class MovieController {
  private static final Integer PAGE_SIZE = 6;
  private static final String SELECT_CLAUSE = 'SELECT id, name__c, category__c, description__c,Rating__c FROM Movie__c';
  @AuraEnabled
  public static void createMovie(Movie__c movie, List<Id> actorIds) {
    List<MovieActor__c> movieActors = new List<MovieActor__c>();
    try {
      SObjectAccessDecision movieDecision = Security.stripInaccessible(
        AccessType.CREATABLE,
        new List<Movie__c>{ movie }
      );
      insert movieDecision.getRecords();
      Id movieId = movieDecision.getRecords().get(0).Id;
      for (Id actorId : actorIds) {
        MovieActor__c movieActor = new MovieActor__c();
        movieActor.Actor__c = actorId;
        movieActor.Movie__c = movieId;
        movieActor.key__c = actorId + '' + movieId;
        movieActors.add(movieActor);
      }
      SObjectAccessDecision movieActorDecision = Security.stripInaccessible(
        AccessType.CREATABLE,
        movieActors
      );
      insert movieActorDecision.getRecords();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void updateMovie(Movie__c movie, List<Id> actorIds) {
    List<MovieActor__c> movieActors = new List<MovieActor__c>();
    try {
      update movie;
      handleRemovedActor(movie.Id, actorIds);
      for (Id actorId : actorIds) {
        MovieActor__c movieActor = new MovieActor__c();
        movieActor.Actor__c = actorId;
        movieActor.Movie__c = movie.Id;
        movieActor.key__c = actorId + '' + movie.Id;
        movieActors.add(movieActor);
      }
      upsert movieActors key__c;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  private static void handleRemovedActor(Id movieId, List<Id> actorIds) {
    delete [
      SELECT Actor__c
      FROM MovieActor__c
      WHERE Movie__c = :movieId AND Actor__c NOT IN :actorIds
    ];
  }

  @AuraEnabled(Cacheable=true)
  public static MovieDTO getMovies(Integer pageNumber, String searchTerm) {
    Integer offset = PAGE_SIZE * (pageNumber - 1);
    String query = SELECT_CLAUSE;
    String movieNameQueryParam = '%' + searchTerm + '%';
    query += ' WHERE name__c like :movieNameQueryParam';
    query += ' ORDER BY CreatedDate DESC';
    query += ' LIMIT :PAGE_SIZE OFFSET :offset';
    MovieDTO result = new MovieDTO();
    result.totalItemCount = Database.countQuery(
      'SELECT count() FROM Movie__c WHERE name__c like :movieNameQueryParam'
    );
    result.pageSize = PAGE_SIZE;
    result.movies = Database.query(query);
    return result;
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
