import { LightningElement, track } from "lwc";
import {
  createMessageContext,
  releaseMessageContext,
  APPLICATION_SCOPE,
  subscribe,
  unsubscribe,
  publish
} from "lightning/messageService";
import MoviePreview from "@salesforce/messageChannel/MoviePreview__c";
import deleteMovie from "@salesforce/apex/MovieController.deleteMovie";
import RefreshMoviesList from "@salesforce/messageChannel/RefreshMoviesList__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import DeleteMovieConfirmationModal from "c/deleteMovieConfirmationModal";

export default class MoviePreviewLwc extends LightningElement {
  context = createMessageContext();
  @track subscription = null;
  connectedCallback() {
    this.handleSubscribe();
  }
  disconnectedCallback() {
    this.unsubscribe();
  }
  @track movie;
  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.context,
      MoviePreview,
      (message) => {
        if (message.movie) {
          this.movie = message.movie;
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleUnsubscribe() {
    unsubscribe(this.subscription);
    this.subscription = undefined;
    releaseMessageContext(this.context);
  }

  async handleDeleteMovie() {
    const result = await DeleteMovieConfirmationModal.open({
      size: "small"
    });
    if (result === "delete") {
      deleteMovie({ movie: this.movie })
        .then(() => {
          publish(this.context, RefreshMoviesList, {
            searchTerm: ""
          });
          const event = new ShowToastEvent({
            title: "Success!",
            message: "The movie has been deleted",
            variant: "success"
          });
          this.dispatchEvent(event);
          this.hidePreview();
        })
        .catch((error) => console.log(error));
    }
  }
  hidePreview() {
    this.movie = null;
  }
}
