import { LightningElement, api } from "lwc";
import { createMessageContext, publish } from "lightning/messageService";
import updateMovie from "@salesforce/apex/MovieController.updateMovie";
import RefreshMoviesList from "@salesforce/messageChannel/refreshMoviesList__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getActorNamesByMovieId from "@salesforce/apex/ActorsController.getActorNamesByMovieId";
import MovieModal from "c/movieModal";
import MoviePreview from "@salesforce/messageChannel/MoviePreview__c";

export default class UpdateMovie extends LightningElement {
  movieActors;
  async handleDispalyModal() {
    await getActorNamesByMovieId({ movieId: this.movie.Id })
      .then((data) => {
        this.movieActors = data.map((movieActor) => movieActor.Actor__c);
        MovieModal.open({
          label: "Update the movie",
          handleUpdateMovie: this.handleUpdateMovie,
          movieActors: this.movieActors,
          movie: this.movie,
          actionType: "Update"
        });
      })
      .catch((error) => console.log(error));
  }

  @api movie;
  context = createMessageContext();
  handleUpdateMovie(modal, movie) {
    updateMovie(movie)
      .then(() => {
        publish(this.context, RefreshMoviesList, { searchTerm: "" });
        const toastEvent = new ShowToastEvent({
          title: "Success!",
          message: "The movie has been updated",
          variant: "success"
        });
        this.dispatchEvent(toastEvent);
        modal.close();
        publish(this.context, MoviePreview, { hidePreview: true });
      })
      .catch((error) => console.log(error));
  }
}
