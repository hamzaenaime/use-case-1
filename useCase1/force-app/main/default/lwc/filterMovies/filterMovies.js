import { LightningElement } from "lwc";
import { createMessageContext, publish } from "lightning/messageService";
import RefreshMoviesList from "@salesforce/messageChannel/RefreshMoviesList__c";

export default class FilterMoviesLwc extends LightningElement {
  context = createMessageContext();
  searchTerm = "";
  handleSearchKeyChange(event) {
    this.searchTerm = event.detail.value;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      publish(this.context, RefreshMoviesList, {
        searchTerm: this.searchTerm,
        pageNumber: 1 // reset page number to 1 when searching
      });
    }, 1500);
  }
}
