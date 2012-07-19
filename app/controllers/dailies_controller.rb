class DailiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter 'kontrol', :only => [:new, :edit, :update, :destroy, :create]

  def kontrol
    @temp = Probation.find(params[:probation_id])
    if @temp.user_id != session[:user].id and current_user.role != "admin"
      redirect_to probations_path
    end
  end

  def index
    @daily = Daily.order("created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @daily }
    end
  end

  def edit
    @probation = Probation.find(params[:probation_id])
    @daily  = Daily.find(params[:id])
    @probation_all = Probation.where(:user_id => session[:user].id).order("probation_name ASC")
  end

  def new
    @probation = Probation.find(params[:probation_id])
    @daily = @probation.daily.new
    @probation_all = Probation.where(:user_id => session[:user].id).order("probation_name ASC")
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @probation }
    end
  end

  def show
    @probation = Probation.find(params[:probation_id])
    @daily = Daily.find(params[:id])
    @comment = @daily.comment.paginate(:page => params[:page], :per_page => 5).order("created_at DESC")

    respond_to do |format|
      format.html {render :action => 'show'}# show.html.erb
      format.pdf  { ppdf }
      end
  end

    def ppdf
      pdf = Prawn::Document.new
      pdf.text  "#{@probation.probation_name.upcase}", :size => 15, :style => :bold, :align => :center
      pdf.text "( #{@probation.started_at} - #{@probation.finished_at} )", :size => 10, :align => :center
      pdf.move_down(30)

        pdf.draw_text "Subject : ", :size => 13, :style => :bold, :at => [20, 650]
        pdf.text_box "#{@daily.subject.capitalize}     (#{@daily.created_at.to_date})", :size => 12, :at => [80, 657]
        pdf.draw_text "Content : ", :size => 13, :style => :bold, :at => [20, 630]
        pdf.text_box "#{@daily.content.capitalize}", :size => 12, :at => [80, 637], :width => 500

      pdf.move_down(10)
      filename = File.join(Rails.root, "app/report", "document.pdf")
      pdf.render_file filename
      send_file filename, :filename => "document.pdf", :type => "application/pdf"
    end

  def update
    params[:probation_id] = params[:daily][:probation_id]
    @daily = Daily.find(params[:id])
    #@probation_temp =  Probation.new(params[:probation])
    #if @probation_temp.started_at > @probation_temp.finished_at
    # @probation_temp.destroy
    #render('edit')
    #return
    #end
    respond_to do |format|
      if @daily.update_attributes(params[:daily])
        format.html { redirect_to [@daily.probation, @daily], :notice => 'Daily was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @daily.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create
    params[:probation_id] = params[:daily][:probation_id]
    @probation = Probation.find(params[:probation_id])
    @probation_all = Probation.where(:user_id => session[:user].id).order("probation_name ASC")
    @daily = @probation.daily.new(params[:daily])

    respond_to do |format|
      if@daily.save
        format.html { redirect_to @probation, :notice => 'Daily was successfully created.' }
        format.json { render :json => @probation, :status => :created, :location => @probation }
      else
        format.html { render :action => "new" }
        format.json { render :json => @probation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @daily = Daily.find(params[:id])
    @probation = @daily.probation

    @comment = @daily.comment
    @comment.each do  |comment|
      comment.destroy
    end

    @daily.destroy

    respond_to do |format|
      format.html { redirect_to @probation, :notice => 'Daily was successfully deleted.' }
      format.json { head :ok }
    end
  end
end
