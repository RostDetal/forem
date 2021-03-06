module Forem
  class ForumsController < Forem::ApplicationController
    load_and_authorize_resource :class => 'Forem::Forum', :only => :show
    helper 'forem/topics'

    def index
      @categories = Forem::Category.all.order(:sort_field => :desc)
      @last_topics = Forem::Topic.all.order(:updated_at => :desc).limit(9)
      @last_topics_created = Forem::Topic.all.order(:created_at => :desc).limit(9)
      @users = Spree::UserAdjustment.all.sample(6)
    end

    def show
      authorize! :show, @forum
      register_view

      @topics = if forem_admin_or_moderator?(@forum)
        @forum.topics
      else
        @forum.topics.visible.approved_or_pending_review_for(forem_user)
      end

      @topics = @topics.by_pinned_or_most_recent_post

      # Kaminari allows to configure the method and param used
      @topics = @topics.send(pagination_method, params[pagination_param]).per(Forem.per_page)

      respond_to do |format|
        format.html
        format.atom { render :layout => false }
      end
    end

    private
    def register_view
      @forum.register_view_by(forem_user)
    end

    def accurate_title
      if !@forum.nil?
        @title = t("forem.forums.index.forum") +" - "+ @forum.name
      else
        @title = t("forem.forums.index.forum")
      end
    end

  end
end
