public with sharing class MovieActorTriggerHandler extends TriggerHandler {
  public override void afterInsert() {
    Set<Id> newMovieIds = new Set<Id>();
    Set<Id> newActorIds = new Set<Id>();
    for (MovieActor__c movieActor : (List<MovieActor__c>) Trigger.new) {
      newMovieIds.add(movieActor.Movie__c);
      newActorIds.add(movieActor.Actor__c);
    }
    this.calculateGenderPercentagesPerMovie(newMovieIds);
    this.calculateNumberOfMoviesPerActor(newActorIds);
  }
  private void calculateNumberOfMoviesPerActor(Set<Id> newActorIds) {
    List<MovieActor__c> movieActors = [
      SELECT Actor__c, Movie__c
      FROM MovieActor__c
      WHERE Actor__c IN :newActorIds
      WITH SECURITY_ENFORCED
    ];

    Map<Id, List<Id>> actorIdWithMovies = new Map<Id, List<Id>>();
    for (MovieActor__c movieActor : movieActors) {
      if (actorIdWithMovies.keySet().contains(movieActor.Actor__c)) {
        actorIdWithMovies.get(movieActor.Actor__c).add(movieActor.Movie__c);
      } else {
        List<Id> movies = new List<Id>{ movieActor.Movie__c };
        actorIdWithMovies.put(movieActor.Actor__c, movies);
      }
    }

    List<Actor__c> updatedActors = new List<Actor__c>();
    for (Actor__c actor : [
      SELECT Id, Number_of_movies__c
      FROM Actor__c
      WHERE Id IN :newActorIds
      WITH SECURITY_ENFORCED
    ]) {
      if (actorIdWithMovies.containsKey(actor.Id)) {
        actor.Number_of_movies__c = actorIdWithMovies.get(actor.Id).size();
        updatedActors.add(actor);
      }
    }
    SObjectAccessDecision decision = Security.stripInaccessible(
      AccessType.UPDATABLE,
      updatedActors
    );
    update decision.getRecords();
  }
  private void calculateGenderPercentagesPerMovie(Set<Id> newMovieIds) {
    List<MovieActor__c> movieActors = [
      SELECT Movie__c, Actor__c, Actor__r.Gender__c
      FROM MovieActor__c
      WHERE Movie__c IN :newMovieIds
      WITH SECURITY_ENFORCED
    ];
    Map<Id, Map<String, List<Id>>> movieIdWithActors = this.constructMapOfMoviesWithActors(
      movieActors
    );
    this.updateMovies(movieIdWithActors, newMovieIds);
  }
  private void updateMovies(
    Map<Id, Map<String, List<Id>>> movieIdWithActors,
    Set<Id> newMovieIds
  ) {
    List<Movie__c> updatedMovies = new List<Movie__c>();
    for (Movie__c movie : [
      SELECT Id, FemaleActorsPercentage__c, MaleActorsPercentage__c
      FROM Movie__c
      WHERE Id IN :newMovieIds
      WITH SECURITY_ENFORCED
    ]) {
      Map<String, List<Id>> actorsOfMovie = movieIdWithActors.get(movie.Id);
      Integer totalMales = 0;
      Integer totalFemales = 0;
      if (actorsOfMovie != null && actorsOfMovie.keySet().contains('Male')) {
        totalMales = actorsOfMovie.get('Male').size();
      }
      if (actorsOfMovie != null && actorsOfMovie.keySet().contains('Female')) {
        totalFemales = actorsOfMovie.get('Female').size();
      }
      Integer totalActorsOfMovie = totalFemales + totalMales;
      if (totalActorsOfMovie != 0) {
        movie.FemaleActorsPercentage__c =
          100 *
          totalFemales /
          totalActorsOfMovie;
        movie.MaleActorsPercentage__c = 100 * totalMales / totalActorsOfMovie;
      } else {
        movie.FemaleActorsPercentage__c = 0;
        movie.MaleActorsPercentage__c = 0;
      }
      updatedMovies.add(movie);
    }
    SObjectAccessDecision decision = Security.stripInaccessible(
      AccessType.UPDATABLE,
      updatedMovies
    );
    update decision.getRecords();
  }
  private Map<Id, Map<String, List<Id>>> constructMapOfMoviesWithActors(
    List<MovieActor__c> movieActors
  ) {
    Map<Id, Map<String, List<Id>>> movieIdWithActors = new Map<Id, Map<String, List<Id>>>();
    for (MovieActor__c movieActor : movieActors) {
      if (movieIdWithActors.keySet().contains(movieActor.Movie__c)) {
        if (
          movieIdWithActors.get(movieActor.Movie__c)
            .keySet()
            .contains(movieActor.Actor__r.Gender__c)
        ) {
          movieIdWithActors.get(movieActor.Movie__c)
            .get(movieActor.Actor__r.Gender__c)
            .add(movieActor.Actor__c);
        } else {
          List<Id> actors = new List<Id>();
          actors.add(movieActor.Actor__c);
          movieIdWithActors.get(movieActor.Movie__c)
            .put(movieActor.Actor__r.Gender__c, actors);
        }
      } else {
        Map<String, List<Id>> actorsByGender = new Map<String, List<Id>>();
        List<Id> actors = new List<Id>();
        actors.add(movieActor.Actor__c);
        actorsByGender.put(movieActor.Actor__r.Gender__c, actors);
        movieIdWithActors.put(movieActor.Movie__c, actorsByGender);
      }
    }
    return movieIdWithActors;
  }
  public override void afterDelete() {
    Set<Id> newMovieIds = new Set<Id>();
    Set<Id> newActorIds = new Set<Id>();
    for (MovieActor__c movieActor : (List<MovieActor__c>) Trigger.old) {
      newMovieIds.add(movieActor.Movie__c);
      newActorIds.add(movieActor.Actor__c);
    }
    this.calculateGenderPercentagesPerMovie(newMovieIds);
    this.calculateNumberOfMoviesPerActor(newActorIds);
  }
}
