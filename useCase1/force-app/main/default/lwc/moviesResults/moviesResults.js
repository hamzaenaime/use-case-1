import { LightningElement, wire, track } from "lwc";
import getMovies from "@salesforce/apex/MovieController.getMovies";
import { refreshApex } from "@salesforce/apex";
import {
  createMessageContext,
  releaseMessageContext,
  APPLICATION_SCOPE,
  subscribe,
  unsubscribe,
  publish
} from "lightning/messageService";
import RefreshMoviesList from "@salesforce/messageChannel/RefreshMoviesList__c";
import MoviePreview from "@salesforce/messageChannel/MoviePreview__c";

export default class MoviesResultsLwc extends LightningElement {
  context = createMessageContext();
  @track subscription = null;
  connectedCallback() {
    this.handleSubscribe();
  }
  disconnectedCallback() {
    this.unsubscribe();
  }
  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.context,
      RefreshMoviesList,
      (message) => {
        if (message.searchTerm !== undefined) {
          this.searchTerm = message.searchTerm;
        }
        if (message.pageNumber) {
          this.pageNumber = message.pageNumber;
        }
        refreshApex(this.moviesPayload);
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleUnsubscribe() {
    unsubscribe(this.subscription);
    this.subscription = undefined;
    releaseMessageContext(this.context);
  }
  moviesPayload;
  pageNumber = 1;
  searchTerm = "";
  showPagination;
  @wire(getMovies, { pageNumber: "$pageNumber", searchTerm: "$searchTerm" })
  setMovies(payload) {
    console.log(payload);
    this.moviesPayload = payload;
    if (payload.data) {
      this.showPagination = payload.data.totalItemCount > 6;
    }
    if (payload.error) {
      console.log(payload.error);
    }
  }

  handlePreview(event) {
    const movie = event.target.movie;
    publish(this.context, MoviePreview, { movie });
  }
}