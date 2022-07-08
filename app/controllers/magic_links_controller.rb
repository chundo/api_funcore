class MagicLinksController < ApplicationController
  before_action :set_magic_link, only: %i[ show update destroy ]

  # GET /magic_links
  def index
    @magic_links = MagicLink.all

    render json: @magic_links
  end

  # GET /magic_links/1
  def show
    render json: @magic_link
  end

  # POST /magic_links
  def create
    @magic_link = MagicLink.new(magic_link_params)

    if @magic_link.save
      render json: @magic_link, status: :created, location: @magic_link
    else
      render json: @magic_link.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /magic_links/1
  def update
    if @magic_link.update(magic_link_params)
      render json: @magic_link
    else
      render json: @magic_link.errors, status: :unprocessable_entity
    end
  end

  # DELETE /magic_links/1
  def destroy
    @magic_link.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_magic_link
      @magic_link = MagicLink.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def magic_link_params
      params.require(:magic_link).permit(:token, :expires_at, :user_id, :active)
    end
end
