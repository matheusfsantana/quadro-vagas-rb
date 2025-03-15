class MassiveLoad
  attr_accessor :file, :errors, :success

  def initialize(file)
    @file = file
    @success = 0
    @errors = []
  end

  def process_file
    return unless file
    file.open.each_with_index do |row, index|
      process_line(row, index+1)
    end
  end

  private

  def process_line(row, index)
    first_character = row.split(",").first.upcase
    attributes = row.split(",")[1..-1]

    case first_character
    when "U" then validate_user(attributes, index)
    when "E" then validate_company(attributes, index)
    when "V" then validate_job(attributes, index)
    else  errors << "Linha #{index+1}: Linha vazia ou inválida"
    end
  end

  def validate_user(attr, index)
    new_user = User.new(
      name: attr[0],
      last_name: attr[1],
      email_address: attr[2],
      password: "password123",
      password_confirmation: "password123"
    )

    @success +=1 if new_user.save
    new_user.errors.full_messages.each { |err| @errors << "Linha #{index}: #{err}" } if new_user.errors.any?
  end

  def validate_company(attr, index)
    new_company = CompanyProfile.new(
      name: attr[0],
      website_url: attr[1],
      contact_email: attr[2],
      user_id: attr[3].to_i
    )
    new_company.logo = File.open(Rails.root.join("spec/support/files/logo.jpg"), filename: "logo.jpg")

    @success +=1 if new_company.save
    new_company.errors.full_messages.each { |err| @errors << "Linha #{index}: #{err}" } if new_company.errors.any?
  end

  def validate_job(attr, index)
    @errors << "Linha #{index}: Não foi encontrado nenhum JobType com esse id" unless JobType.exists?(attr[5].to_i)
    @errors << "Linha #{index}: Não foi encontrado nenhum ExperienceLevel com esse id" unless ExperienceLevel.exists?(attr[7].to_i)
    @errors << "Linha #{index}: Não foi encontrado nenhuma CompanyProfile com esse id" unless CompanyProfile.exists?(attr[8].to_i)

    new_job = JobPosting.new(
      title: attr[0],
      salary: attr[1],
      salary_currency: JobPosting.enum_string_to_symbol(attr[2]),
      salary_period: JobPosting.enum_string_to_symbol(attr[3]),
      work_arrangement: JobPosting.enum_string_to_symbol(attr[4]),
      job_type_id: attr[5].to_i,
      job_location: attr[6],
      experience_level_id: attr[7].to_i,
      company_profile_id: attr[8].to_i,
      description: "Default description"
    )

    @success +=1 if new_job.save
    new_job.errors.full_messages.each { |err| @errors << "Linha #{index}: #{err}" } if new_job.errors.any?
  end
end
