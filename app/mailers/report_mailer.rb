class ReportMailer < ApplicationMailer
  DEFAULT_RECIPIENTS = ["mjbostler@darumanyc.com"]
  
  def report_email( opts )
    @data_file = opts[:data_file]
    @zip_file = opts[:zip_file]
    recipients = opts[:recipients] || DEFAULT_RECIPIENTS
    zip_basename = File.basename( @zip_file )
    subject = "Attribution Report#{@zip_file ? ": #{zip_basename}" : ''}"
    
    attachments[zip_basename] = File.read( @zip_file )
    mail to: recipients, subject: subject
  end
end
