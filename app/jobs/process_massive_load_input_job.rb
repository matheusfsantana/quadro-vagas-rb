class ProcessMassiveLoadInputJob < ApplicationJob
  queue_as :default

  def perform(massive_load_input_id)
    massive_load_input = MassiveLoadInput.find(massive_load_input_id)

    begin
      massive_load_input.process_file
      massive_load_input.processed!
    rescue Exception => e
      massive_load_input.failed!
      Rails.logger.error("Erro ao processar #{massive_load_input_id}: #{e.message}")
    end
  end
end
