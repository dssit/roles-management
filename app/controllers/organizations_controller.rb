class OrganizationsController < ApplicationController
  filter_access_to :all, :attribute_check => true
  filter_access_to :index, :attribute_check => true, :load_method => :load_organizations

  # GET /organizations.json
  # It's assumed that organizations are never scoped per-user or per-permission. If this
  # changes, the @cache_key must change to reflect such scoped nature.
  def index
    @cache_key = "organization/" + (params[:q] ? params[:q] : '') + '/' + Digest::MD5.hexdigest(@organizations.map(&:cache_key).to_s) + params[:tree].to_s + params[:q].to_s

    if params[:tree]
      Rails.logger.debug "Rendering organization index tree"
      respond_to do |format|
        format.html { render "organizations/index_tree" }
      end
    else
      Rails.logger.debug "Rendering organization index (non-tree)"
      respond_to do |format|
        format.html { render "organizations/index" }
      end
    end
  end

  # GET /organizations/1.json
  def show
    respond_to do |format|
      format.json { render json: @organization }
    end
  end

  private

  def load_organizations
    if params[:q]
      organizations_table = Organization.arel_table

      # Search login IDs in case of an entity-search but looking for person by login ID
      # TODO: add equivalent .with_permissions_to(read:)
      @organizations = Organization.where(organizations_table[:name].matches("%#{params[:q]}%").or(organizations_table[:dept_code].matches("%#{params[:q]}%")))

      logger.debug "Organizations#index searching for '#{params[:q]}'. Found #{@organizations.length} results."
    else
      # TODO: add equivalent .with_permissions_to(read:)
      @organizations = Organization.all

      if params[:tree]
        @top_level_organizations = []

        @organizations.each do |organization|
          if organization.parent_organizations.length == 0
            @top_level_organizations << organization
          end
        end
      end
    end
  end
end
