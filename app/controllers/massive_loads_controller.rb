class MassiveLoadsController < ApplicationController
  before_action :only_for_admin

  def new ; end

  def create
    @file = MassiveLoad.new(params[:arquivo])
    @file.process_file
    flash.now[:notice] = "Carga realizada com sucesso!"
    render :new, status: :ok
  end


  private

  def only_for_admin
    redirect_to root_path, alert: t(".unauthorized") unless Current.user && Current.user&.admin?
  end
end
