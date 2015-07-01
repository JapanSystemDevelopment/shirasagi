class Cms::FilesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter
  include SS::FileFilter

  model Cms::File

  navi_view "cms/main/navi"

  private
    def set_crumbs
      @crumbs << [:"cms.file", action: :index]
    end

    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site }
    end

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user, site: @cur_site)

      @items = @model.site(@cur_site).
        allow(:read, @cur_user).
        search(params[:s]).
        order_by(filename: 1).
        page(params[:page]).per(50)
    end
end