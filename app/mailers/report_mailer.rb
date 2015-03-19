class ReportMailer < ApplicationMailer
  DEFAULT_RECIPIENTS = ["mjbostler@darumanyc.com"]
  
  def report_email( opts )
    @data_file = opts[:data_file]
    recipients = opts[:recipients] || DEFAULT_RECIPIENTS
    subject = "Attribution Report#{@data_file ? ' (with actual report)' : ''}"
    
    attachments[@data_file.filename] = File.read( @data_file.path )
    mail to: recipients, subject: subject
  end
end
