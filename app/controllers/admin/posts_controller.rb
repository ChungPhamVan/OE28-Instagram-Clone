class Admin::PostsController < ApplicationController
  before_action :logged_in_user, :is_admin
  before_action :load_post, except: %i(index create)
  before_action :search, :sort, only: :index

  def index
    @posts ||= Post.order_by_created_at
                   .page(params[:page])
                   .per Settings.user.previews_per_page
    @post_hash = {
      post: Post.new,
      posts: @posts,
      title: t(".posts"),
      page: params[:page],
      type: params[:type],
      sort_value: params[:sort_value],
      text_search: params[:text_search]
    }
    respond_to :html, :js
  end

  def create
    @post = current_user.posts.build post_params
    if @post.save
      flash[:success] = t ".upload_successfully"
    else
      flash[:danger] = t ".upload_fail"
    end
    redirect_back fallback_location: root_path
  end

  def edit; end

  def update
    if @post.update_post post_params
      flash[:success] = t ".update_success"
      respond_to :js
    else
      flash.now[:danger] = t ".update_fail"
      render "posts/edit"
    end
  end

  def destroy
    if @post.destroy
      flash[:success] = t ".destroy_success"
    else
      flash[:danger] = t ".destroy_failed"
    end
    redirect_back fallback_location: root_path
  end

  private

  def sort
    return unless params[:type].eql? Settings.sort_post.type

    posts_search = Post.search_by_description_username(params[:text_search])
    @posts = case params[:sort_value].to_i
             when Settings.sort_post.updated_at
               posts_search.order_by_updated_at
                           .page(params[:page]).per Settings.user.previews_per_page
             when Settings.sort_post.description
               posts_search.order_by_description
                           .page(params[:page]).per Settings.user.previews_per_page
             else
               posts_search.order_by_created_at
                           .page(params[:page]).per Settings.user.previews_per_page
             end
  end

  def search
    return unless params[:type].eql? Settings.search.type

    @posts = Post.search_by_description_username(params[:text_search])
                 .order_by_created_at
                 .page(params[:page]).per Settings.user.previews_per_page
  end
end
