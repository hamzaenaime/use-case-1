import { LightningElement } from "lwc";
import { createMessageContext, publish } from "lightning/messageService";
import RefreshMoviesList from "@salesforce/messageChannel/RefreshMoviesList__c";
import createMovie from "@salesforce/apex/MovieController.createMovie";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MovieModal from "c/movieModal";

export default class NewMovie extends LightningElement {
  context = createMessageContext();
  async handleDispalyModal() {
    await MovieModal.open({
      label: "Create new movie",
      handleSaveMovie: this.handleSaveMovie,
      actionType: "Create"
    });
  }
  handleSaveMovie(modal, movie) {
    createMovie(movie)
      .then(() => {
        publish(this.context, RefreshMoviesList, { searchTerm: "" });
        const toastEvent = new ShowToastEvent({
          title: "Success!",
          message: "The movie has been created",
          variant: "success"
        });
        this.dispatchEvent(toastEvent);
        modal.close();
      })
      .catch((error) => {
        const toastEvent = new ShowToastEvent({
          title: "Error!",
          message: error.body ? error.body.message : "An error has occured",
          variant: "error"
        });
        this.dispatchEvent(toastEvent);
      });
  }
}
