class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    allowed_sorts = %w[title release_date]
    need_redirect = false

    ratings_hash = 
      if params[:ratings].present?
        params[:ratings].to_unsafe_h
      elsif session[:ratings].present?
        need_redirect = true
        session[:ratings]
      else
        @all_ratings.index_with { '1' }
      end
    @ratings_to_show = ratings_hash.keys
    @ratings_hash = ratings_hash
    session[:ratings] = ratings_hash
    
    @sort_by = 
      if allowed_sorts.include?(params[:sort_by])
        params[:sort_by]
      elsif session[:sort_by].present?
        need_redirect = true
        session[:sort_by]  
      else
        nil
      end 
    session[:sort_by] = @sort_by
    
    if need_redirect
      redirect_to movies_path(sort_by: @sort_by, ratings: ratings_hash) and return
    end

    @movies = Movie.where(rating: @ratings_to_show)
    @movies = @movies.order(@sort_by => :asc) if @sort_by
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
