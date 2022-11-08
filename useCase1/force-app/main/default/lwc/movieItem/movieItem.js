import { LightningElement, api } from "lwc";
import getImageUrl from "@salesforce/apex/ImageUploaderController.getImageUrl";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class MovieItem extends LightningElement {
  @api movie;
  url;
  loading = true;
  connectedCallback() {
    if (this.movie) {
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
  }
}
