import { track, wire, api } from "lwc";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import getActors from "@salesforce/apex/ActorsController.getActors";
import Movie__c from "@salesforce/schema/MovieActor__c.Movie__c";
import Category__c from "@salesforce/schema/Movie__c.Category__c";
import { createMessageContext } from "lightning/messageService";
import LightningModal from "lightning/modal";

export default class MovieModal extends LightningModal {
  context = createMessageContext();
  @wire(getObjectInfo, { objectApiName: Movie__c }) movieMetaData;
  @api handleSaveMovie;
  @api handleUpdateMovie;
  @api movie;
  @api movieActors;
  @api actionType;
  movieCategories;
  @wire(
    getPicklistValues,

    {
      recordTypeId: "$movieMetaData.data.defaultRecordTypeId",

      fieldApiName: Category__c
    }
  )
  setCategoryPicklistOptions({ error, data }) {
    if (data) {
      this.movieCategories = data.values;
    } else if (error) {
      console.log(error);
    }
  }

  connectedCallback() {
    if (this.movie) {
      this.movieFields = {
        ...this.movieFields,
        Id: this.movie.Id,
        movieName: this.movie.Name__c,
        movieDescription: this.movie.Description__c,
        movieType: this.movie.Category__c,
        movieRating: this.movie.Rating__c
      };
    }
  }

  @track actorsList;
  @wire(getActors) setActors({ error, data }) {
    if (data) {
      this.actorsList = data.map((actor) => ({
        ...actor,
        label: actor.Name,
        value: actor.Id,
        addedToMovie:
          this.actionType === "Create"
            ? false
            : this.movieActors.includes(actor.Id)
      }));
      this.updateActorsPickListValues();
    } else if (error) {
      console.log(error);
    }
  }

  actorsPicklistValues = [];
  updateActorsPickListValues() {
    this.actorsPicklistValues = this.actorsList.filter(
      (actor) => actor.addedToMovie === false
    );
  }
  handleAddActor() {
    if (this.movieFields.movieActor) {
      this.actorsList.forEach((actor) => {
        if (actor.value === this.movieFields.movieActor) {
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
  movieFields = {};
  handleChange(event) {
    this.movieFields = {
      ...this.movieFields,
      [event.target.name]: event.detail.value
    };
  }
  loading = false;
  handleSave() {
    if (this.isInputValid()) {
      this.loading = true;
      const actorIds = this.actorsList
        .filter((actor) => actor.addedToMovie === true)
        .map((actor) => actor.Id);
      const insertedMovie = {
        movie: {
          Name__c: this.movieFields.movieName,
          Category__c: this.movieFields.movieType,
          Description__c: this.movieFields.movieDescription,
          Rating__c: this.movieFields.movieRating
        },
        actorIds: actorIds
      };
      this.handleSaveMovie(this, insertedMovie);
    }
  }

  handleUpdate() {
    if (this.isInputValid()) {
      this.loading = true;
      const actorIds = this.actorsList
        .filter((actor) => actor.addedToMovie === true)
        .map((actor) => actor.Id);
      const updatedMovie = {
        movie: {
          Id: this.movieFields.Id,
          Name__c: this.movieFields.movieName,
          Category__c: this.movieFields.movieType,
          Description__c: this.movieFields.movieDescription,
          Rating__c: this.movieFields.movieRating
        },
        actorIds: actorIds
      };
      this.handleUpdateMovie(this, updatedMovie);
    }
  }

  handleCancel() {
    this.close();
  }
  handleAction() {
    if (this.actionType === "Create") {
      this.handleSave();
    } else if (this.actionType === "Update") {
      this.handleUpdate();
    }
  }

  isInputValid() {
    const areInputsValid = [];
    this.template.querySelectorAll(".validate").forEach((inputField) => {
      if (!inputField.checkValidity()) {
        inputField.reportValidity();
        areInputsValid.push(false);
      } else {
        areInputsValid.push(true);
      }
    });
    return areInputsValid.every(Boolean);
  }

  @track documentId;
  handleDocumentId(event) {
    this.documentId = event.detail;
  }
}
