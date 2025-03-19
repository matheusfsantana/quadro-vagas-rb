class MassiveLoadInputsController < ApplicationController
  before_action :only_for_admin

  def new
    @massive_load_input = MassiveLoadInput.new
  end

  def create
    @massive_load_input = MassiveLoadInput.new(massive_load_input_params)
    if @massive_load_input.save
      ProcessMassiveLoadInputJob.perform_later(@massive_load_input.id)
      return redirect_to massive_load_input_path(@massive_load_input)
    end
    flash.now[:alert] = "Algo deu errado!"
    render :new, status: :unprocessable_entity
  end

  def show
    @massive_load_input = MassiveLoadInput.find(params[:id])
  end

  def download_report
    massive_load_input = MassiveLoadInput.find(params[:id])
    errors = massive_load_input.massive_load_report.fail

    report_content = errors.map do |error|
      "Linha: #{error.row_number} - Erro: #{error.description}"
    end.join("\n")

    send_data report_content, filename: "relatorio_erros_#{massive_load_input.id}.txt", type: "text/plain"
  end

  private

  def only_for_admin
    redirect_to root_path, alert: t(".unauthorized") unless Current.user && Current.user&.admin?
  end

  def massive_load_input_params
    params.require(:massive_load_input).permit(:file)
  end
end
