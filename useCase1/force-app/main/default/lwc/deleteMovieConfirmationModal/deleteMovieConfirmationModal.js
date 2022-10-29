import LightningModal from "lightning/modal";

export default class DeleteMovieConfirmationModal extends LightningModal {
  handleDelete() {
    this.close("delete");
  }
  handleCancel() {
    this.close("cancel");
  }
}
