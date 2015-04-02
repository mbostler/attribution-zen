class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  # GET /reports
  # GET /reports.json
  def index
    @reports = []
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
  end

  # GET /reports/new
  def new
    @report = Report.new
  end
  
  # GET /reports/generate
  def generate
    # portfolio_names = ["ginkgo", "bodhi"]
    portfolio_names = ["ginkgo"]
    date = Date.yesterday
    FileUtils.rm_rf Attribution::DataFile::BKP_DIR
    file_names = portfolio_names.map do |name|
      portfolio = Attribution::Portfolio.where( name: name ).first_or_create
      day = Attribution::Day.where( date: date, portfolio_id: portfolio.id ).first_or_create
      data_file = Attribution::DataFile.new( day )
      data_file.create
      data_file.path
    end
    
    zip_filename = "Attribution Reports - #{date.strftime('%-m-%-d-%Y')}.zip"
    Zip::File.open( zip_filename, Zip::File::CREATE ) do |zipfile|
      file_names.each do |fn|
        zipfile.add( File.basename(fn), fn )
      end
    end
    
    ReportMailer.report_email( zip_file: zip_filename ).deliver_now
    FileUtils.rm( zip_filename ) if File.exists?( zip_filename )
    # send_file data_file.path
    redirect_to reports_path, notice: 'Report was successfully generated.'
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.new(report_params)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params[:report]
    end
end
