import { LightningElement, track, wire } from "lwc";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import getActors from "@salesforce/apex/ActorsController.getActors";
import Movie__c from "@salesforce/schema/MovieActor__c.Movie__c";
import Category__c from "@salesforce/schema/Movie__c.Category__c";
import { createMessageContext, publish } from "lightning/messageService";
import RefreshMoviesList from "@salesforce/messageChannel/RefreshMoviesList__c";
import createMovies from "@salesforce/apex/MovieController.createMovies";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class NewMovieModalLWC extends LightningElement {
  context = createMessageContext();
  @wire(getObjectInfo, { objectApiName: Movie__c }) movieMetaData;
  @wire(
    getPicklistValues,

    {
      recordTypeId: "$movieMetaData.data.defaultRecordTypeId",

      fieldApiName: Category__c
    }
  )
  setCategoryPicklistOptions({ error, data }) {
    if (data) {
      this.picklistValues = data.values;
    } else if (error) {
      console.log(error);
    }
  }
  picklistValues;

  @wire(getActors) setActors({ error, data }) {
    if (data) {
      let actors = [];
      data.forEach((actor) => {
        actors.push({
          label: actor.Name,
          value: actor.Name,
          addedToMovie: false
        });
      });
      this.actorsList = actors;
      this.updateActorsPickListValues();
    } else if (error) {
      console.log(error);
    }
  }
  @track actorsList;
  picklistActors = [];

  showModal = false;
  movieName;
  movieType;
  movieDescription;
  movieActor;
  movieRating;
  updateActorsPickListValues() {
    this.picklistActors = this.actorsList.filter(
      (actor) => actor.addedToMovie === false
    );
  }
  onclick() {
    this.showModal = !this.showModal;
  }
  handleAddActor() {
    if (this.movieActor !== undefined && this.movieActor !== "") {
      this.actorsList.forEach((actor) => {
        if (actor.value === this.movieActor) {
          actor.addedToMovie = true;
        }
      });
      this.updateActorsPickListValues();
    }
  }

  handleRemoveActor(event) {
    this.actorsList.forEach((actor) => {
      if (actor.value === event.target.value) {
        actor.addedToMovie = false;
      }
    });
    this.updateActorsPickListValues();
  }
  handleChange(event) {
    switch (event.target.name) {
      case "movieName":
        this.movieName = event.detail.value;
        break;
      case "movieType":
        this.movieType = event.detail.value;
        break;
      case "movieDescription":
        this.movieDescription = event.detail.value;
        break;
      case "movieActor":
        this.movieActor = event.detail.value;
        break;
      case "rating":
        this.rating = event.detail.rating;
        break;
      default:
        break;
    }
  }
  handleSaveMovie() {
    const movies = new Array({
      Name__c: this.movieName,
      Category__c: this.movieType,
      Description__c: this.movieDescription
    });
    createMovies({ movies: movies })
      .then(() => {
        publish(this.context, RefreshMoviesList, { searchTerm: "" });
        this.onclick();
        const event = new ShowToastEvent({
          title: "Success!",
          message: "The movie has been created",
          variant: "success"
        });
        this.dispatchEvent(event);
      })
      .catch((error) => {
        const event = new ShowToastEvent({
          title: "Error!",
          message: error,
          variant: "error"
        });
        this.dispatchEvent(event);
      });
  }
}
