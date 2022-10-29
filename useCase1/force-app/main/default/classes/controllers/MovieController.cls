public with sharing class MovieController {
  private static final Integer PAGE_SIZE = 6;
  private static final String SELECT_CLAUSE = 'SELECT id, name__c, category__c, description__c FROM Movie__c';
  @AuraEnabled
  public static void createMovies(Movie__c[] movies) {
    try {
      insert movies;
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
      result.pageSize = PAGE_SIZE > result.totalItemCount
        ? result.totalItemCount
        : PAGE_SIZE;
      result.movies = Database.query(query);
      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void deleteMovies(Movie__c[] movies) {
    try {
      delete movies;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
