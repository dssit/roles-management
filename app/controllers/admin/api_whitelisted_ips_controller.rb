class Admin::ApiWhitelistedIpsController < ApplicationController
  # POST /admin/api_whitelisted_ips.json
  def create
    @address = ApiWhitelistedIp.new(params[:address])

    respond_to do |format|
      if @address.save
        logger.info "#{current_user.loginid}@#{request.remote_ip}: Created new whitelisted IP address, #{params[:address]}."
        format.json { render json: @address, status: :created }
      else
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/api_whitelisted_ips/1.json
  def destroy
    @address = ApiWhitelistedIp.find(params[:id])
    @address.destroy

    logger.info "#{current_user.loginid}@#{request.remote_ip}: Deleted whitelisted IP address, #{params[:address]}."

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end