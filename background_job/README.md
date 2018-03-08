# Upload Users job

In order to keep our customer support team productive, we wanted to move uploading
users into a background worker so they could continue to work and get an update
when their upload was completed.

### Architecture

Our application utilized [Sidekiq](https://github.com/mperham/sidekiq) for asynchronous processing of jobs.

A csv of users is submitted and saved to s3 (not included). This job retrieves
that csv by its filename from s3 and sends it through our user import service (not included).
If all the users were valid, they are added to the database and the upload 
service returns true. Upon successful completion, a mailer is delivered to our 
admin to alert them the upload is complete. If the csv contains invalid users, 
the users are not saved to the database and a mailer is sent to the admin with 
a list of invalid users and the errors that need to be corrected before reimport.