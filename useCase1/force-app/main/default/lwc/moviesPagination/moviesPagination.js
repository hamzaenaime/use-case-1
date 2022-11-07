import { LightningElement, track, api } from "lwc";
import RefreshMoviesList from "@salesforce/messageChannel/RefreshMoviesList__c";
import {
  createMessageContext,
  releaseMessageContext,
  APPLICATION_SCOPE,
  subscribe,
  unsubscribe,
  publish
} from "lightning/messageService";
export default class MoviesPagination extends LightningElement {
  context = createMessageContext();
  @api pageSize;
  @api totalItemCount;
  pageNumber = 1;
  numberOfPages = 1;
  disablePrevious;
  disableNext;
  renderedCallback() {
    this.numberOfPages = Math.ceil(this.totalItemCount / this.pageSize);
    this.disableNext = this.pageNumber >= this.numberOfPages;
    this.disablePrevious = this.pageNumber <= 1;
  }
  handlePageNumberDescrese() {
    if (this.pageNumber > 1) {
      this.pageNumber--;
      publish(this.context, RefreshMoviesList, {
        pageNumber: this.pageNumber
      });
    }
  }
  handlePageNumberIncrease() {
    if (this.pageNumber < this.numberOfPages) {
      this.pageNumber++;
      publish(this.context, RefreshMoviesList, {
        pageNumber: this.pageNumber
      });
    }
  }

  @track subscription = null;
  connectedCallback() {
    this.handleSubscribe();
  }
  disconnectedCallback() {
    this.handleUnsubscribe();
  }
  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.context,
      RefreshMoviesList,
      (message) => {
        if (message.pageNumber) {
          this.pageNumber = message.pageNumber;
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
}
