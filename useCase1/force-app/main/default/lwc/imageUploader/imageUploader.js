import { LightningElement, track } from "lwc";
import saveImage from "@salesforce/apex/ImageUploadController.saveImage";
export default class ImageUploader extends LightningElement {
  @track data;
  documentId;
  get acceptedFormats() {
    return [".png", ".jpg", ".jpeg"];
  }

  handleUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    this.documentId = uploadedFiles[0].documentId;
    saveImage({ documentId: this.documentId })
      .then((data) => {
        this.data = data;
      })
      .catch((error) => console.log(error));
    this.dispatchEvent(
      new CustomEvent("documentidevent", {
        detail: this.documentId
      })
    );
  }
}
