class MassiveLoadInput < ApplicationRecord
  has_one_attached :file
  has_many :massive_load_report

  enum :status, { not_started: 0, failed: 5, processed: 10 }

  def process_file
    file_content = file.download.force_encoding("UTF-8")

    self.total_rows = file_content.each_line.count
    self.save

    file_content.each_line.with_index do |row, index|
      process_line(row, index + 1)
    end
  end

  after_update_commit do
    broadcast_replace_to "report_count_#{self.id}",
      target: "report_#{self.id}",
      partial: "massive_load_inputs/report_count",
      locals: { massive_load_input: self }
  end

  private

  def process_line(row, index)
    first_character = row.split(",").first.upcase
    attributes = row.split(",")[1..-1]

    case first_character
    when "U" then validate_user(attributes, index)
    when "E" then validate_company(attributes, index)
    when "V" then validate_job(attributes, index)
    else
      MassiveLoadReport.create(
        massive_load_input: self,
        record_type: :other,
        status: :fail,
        row_number: index,
        description: "Linha vazia ou inválida")
    end
  end

  def validate_user(attr, index)
    random_pass = SecureRandom.alphanumeric(12)
    new_user = User.new(
      email_address: attr[0],
      name: attr[1],
      last_name: attr[2],
      password: random_pass,
      password_confirmation: random_pass
    )

    if new_user.save
      MassiveLoadReport.create(massive_load_input: self, record_type: :user, status: :success, row_number: index)
    else
      new_user.errors.full_messages.each do |err|
        MassiveLoadReport.create(massive_load_input: self, record_type: :user, status: :fail, row_number: index, description: err)
      end
    end
  end

  def validate_company(attr, index)
    new_company = CompanyProfile.new(
      name: attr[0],
      website_url: attr[1],
      contact_email: attr[2],
      user_id: attr[3].to_i,
      logo: File.open(Rails.root.join("spec/support/files/logo.jpg"), filename: "logo.jpg")
    )

    if new_company.save
      MassiveLoadReport.create(massive_load_input: self, record_type: :company, status: :success, row_number: index)
    else
      new_company.errors.full_messages.each do |err|
        MassiveLoadReport.create(massive_load_input: self, record_type: :company, status: :fail, row_number: index, description: err)
      end
    end
  end

  def validate_job(attr, index)
    MassiveLoadReport.create(
      massive_load_input: self,
      record_type: :job,
      status: :fail,
      row_number: index,
      description: "Não foi encontrado nenhum JobType com esse id"
    ) unless JobType.exists?(attr[6].to_i)

    MassiveLoadReport.create(
      massive_load_input: self,
      record_type: :job,
      status: :fail,
      row_number: index,
      description: "Não foi encontrado nenhum ExperienceLevel com esse id"
    ) unless ExperienceLevel.exists?(attr[8].to_i)

    MassiveLoadReport.create(
      massive_load_input: self,
      record_type: :job,
      status: :fail,
      row_number: index,
      description: "Não foi encontrado nenhuma CompanyProfile com esse id"
    ) unless CompanyProfile.exists?(attr[9].to_i)

    new_job = JobPosting.new(
      title: attr[0],
      description: attr[1],
      salary: attr[2],
      salary_currency: JobPosting.enum_string_to_symbol(attr[3]),
      salary_period: JobPosting.enum_string_to_symbol(attr[4]),
      work_arrangement: JobPosting.enum_string_to_symbol(attr[5]),
      job_type_id: attr[6].to_i,
      job_location: attr[7],
      experience_level_id: attr[8].to_i,
      company_profile_id: attr[9].to_i
    )

    if new_job.save
      MassiveLoadReport.create(massive_load_input: self, record_type: :job, status: :success, row_number: index)
    else
      new_job.errors.full_messages.each do |err|
        MassiveLoadReport.create(massive_load_input: self, record_type: :job, status: :fail, row_number: index, description: err + JobPosting.enum_string_to_symbol(attr[5]).to_s)
      end
    end
  end
end
