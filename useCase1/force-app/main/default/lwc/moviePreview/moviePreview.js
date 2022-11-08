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
import UploadImageModal from "c/uploadImageModal";
import getImageUrl from "@salesforce/apex/ImageUploaderController.getImageUrl";
export default class MoviePreviewLwc extends LightningElement {
  context = createMessageContext();
  @track subscription = null;
  url;
  loading = true;
  connectedCallback() {
    this.handleSubscribe();
  }
  disconnectedCallback() {
    this.handleUnsubscribe();
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
          getImageUrl({ recordId: this.movie.Id })
            .then((data) => {
              this.url = data;
              this.loading = false;
            })
            .catch((error) => {
              console.log(error);
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error!!",
                  message: error.message,
                  variant: "error"
                })
              );
              this.loading = false;
            });
        }
        if (message.hidePreview) {
          this.hidePreview();
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
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success!",
              message: "The movie has been deleted",
              variant: "success"
            })
          );
          this.hidePreview();
        })
        .catch((error) =>
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success!",
              message: "The movie has been deleted " + error,
              variant: "error"
            })
          )
        );
    }
  }
  hidePreview() {
    this.movie = null;
  }
  async handleChangeImage() {
    await UploadImageModal.open({
      size: "medium",
      recordId: this.movie.Id
    });
    this.hidePreview();
    publish(this.context, RefreshMoviesList, { searchTerm: "" });
  }
}
