import { track, api } from "lwc";
import LightningModal from "lightning/modal";
import saveFile from "@salesforce/apex/ImageUploaderController.saveFile";
import setImageUrl from "@salesforce/apex/ImageUploaderController.setImageUrl";
import deleteFiles from "@salesforce/apex/ImageUploaderController.deleteFiles";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class UploadImageModal extends LightningModal {
  handleOkay() {
    this.close();
  }
  @api recordId;
  @track data;
  @track fileName = "";
  @track showLoadingSpinner = false;
  @track isTrue = false;
  filesUploaded = [];
  file;
  fileContents;
  fileReader;
  content;
  MAX_FILE_SIZE = 1500000;

  connectedCallback() {
    this.populateImageUrl();
  }

  handleFilesChange(event) {
    this.fileName = "";
    if (event.target.files.length > 0) {
      if (
        event.target.files[0].type !== "image/jpeg" &&
        event.target.files[0].type !== "image/png"
      ) {
        this.fileName = "Invalid file type!!";
        this.isTrue = true;
      } else {
        this.isTrue = false;
        this.filesUploaded = event.target.files;
        this.fileName = event.target.files[0].name;
      }
    }
  }

  handleSave() {
    if (this.filesUploaded.length > 0) {
      this.uploadHelper();
    } else {
      this.fileName = "Please select file to upload!!";
    }
  }

  handleReplace() {
    if (this.filesUploaded.length > 0) {
      deleteFiles({ recordId: this.recordId })
        .then((data) => {
          console.log(data);
          this.uploadHelper();
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error!!",
              message: error.message,
              variant: "error"
            })
          );
        });
    } else {
      this.fileName = "Please select file to upload!!";
    }
  }

  uploadHelper() {
    this.file = this.filesUploaded[0];
    if (this.file.size > this.MAX_FILE_SIZE) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "File Size is to long",
          variant: "error"
        })
      );
      return;
    }
    this.isTrue = true;
    this.showLoadingSpinner = true;
    this.fileReader = new FileReader();
    this.fileReader.onloadend = () => {
      this.fileContents = this.fileReader.result;
      let base64 = "base64,";
      this.content = this.fileContents.indexOf(base64) + base64.length;
      this.fileContents = this.fileContents.substring(this.content);
      this.saveToFile();
    };
    this.fileReader.readAsDataURL(this.file);
  }

  saveToFile() {
    saveFile({
      recordId: this.recordId,
      strFileName: this.file.name,
      base64Data: encodeURIComponent(this.fileContents)
    })
      .then(() => {
        this.populateImageUrl();
        this.fileName = this.fileName + " - Uploaded Successfully";
        this.isTrue = false;
        this.showLoadingSpinner = false;
        this.filesUploaded = [];
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success!!",
            message: this.file.name + " - Uploaded Successfully!!!",
            variant: "success"
          })
        );
      })
      .catch(() => {});
  }

  populateImageUrl() {
    setImageUrl({ recordId: this.recordId })
      .then((data) => {
        this.data = data;
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!!",
            message: error.message,
            variant: "error"
          })
        );
      });
  }
}
