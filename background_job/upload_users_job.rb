# frozen_string_literal: true

# This job handles getting an uploaded User CSV from s3 and saves it to
# a temporary file to pipe through the CSV import service. A mailer is then
# sent to the admin after the import and then the temp file is deleted from
# the system
#
# UploadUsersJob.perform_later(
#  s3_file.filename,
#  @company,
#  current_admin
# )
class UploadUsersJob < ApplicationJob
  queue_as :default

  AWS_REGION = ENV.fetch('AWS_REGION')
  S3_BUCKET = ENV.fetch('S3_BUCKET_NAME')

  after_perform do |job|
    puts "Done with #{job.inspect}"
    File.unlink(@file.path) if File.exist?(@file.path)
  end

  def perform(*args)
    file_name, company, admin = args
    company.switch!
    @file = retrieve_s3_file(file_name)
    service = CSVHandler::Users::Import.new(@file, company.settings.password)

    if service.call
      AdminMailer.valid_upload_email(admin, company).deliver_now
    else
      invalid_users = service.invalid_users
      error_messages = service.errors.join(', ')
      AdminMailer.invalid_users_email(admin, company, invalid_users, error_messages).deliver_now
    end
  end

  private

  # Documentation used for streaming a file from s3:
  # https://aws.amazon.com/blogs/developer/downloading-objects-from-amazon-s3-using-the-aws-sdk-for-ruby/
  # The target file is written to in binmode since Tempfile defaults to 'w+',
  # this helps to guard us from encoding conversion errors when writing the Tempfile
  def retrieve_s3_file(filename)
    object = Tempfile.open(['user-csv', '.csv'], '/tmp') do |f|
      s3_client.get_object({ bucket: S3_BUCKET, key: filename }, target: f.binmode)
    end

    object.body
  end

  def s3_client
    Aws::S3::Client.new(region: AWS_REGION)
  end
end
