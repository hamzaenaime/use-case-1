trigger MovieActorTrigger on MovieActor__c(after insert, after delete) {
  new MovieActorTriggerHandler().run();
}
