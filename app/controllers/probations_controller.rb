class ProbationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter 'kontrol', :only => [:edit, :update, :destroy]

  def kontrol
    @temp = Probation.find(params[:id])
    if @temp.user_id != session[:user].id and current_user.role != "admin"
      redirect_to probations_path
    end
  end

  def index
    if params[:us_id] != nil
      session[:user] = User.find(params[:us_id])
      params[:us_id] = nil
      redirect_to probations_path
      return
    end
    @probation = Probation.where(:user_id => session[:user].id).paginate(:page => params[:page_1], :per_page => 5).order("finished_at DESC")
    @probation_all = Probation.where('user_id != ?', session[:user].id).paginate(:page => params[:page_2], :per_page => 5).order("finished_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @probation }
    end
  end

  def edit
    @probation = Probation.find(params[:id])

  end

  def new
    if User.find(session[:user].id).university.nil?
      #if session[:user].id == current_user.id
        redirect_to edit_user_registration_path, :notice => "You must complete your profil "
      #else
      #  redirect_to edit_user_path(session[:user])
      #end
      return
    end
    @probation = Probation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @probation }
    end
  end

  def show
    @probation = Probation.find(params[:id])
    if @probation.user_id == session[:user].id
      @daily = @probation.daily.paginate(:page => params[:page], :per_page => 5)
      @daily_pdf = @probation.daily.all
    else
      @daily = @probation.daily.where(:status => true).paginate(:page => params[:page], :per_page => 5)
      @daily_pdf = @probation.daily.where(:status => true)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @probation }
      format.pdf  { ppdf }
    end
  end

  def update
    @probation = Probation.find(params[:id])
    #@probation_temp =  Probation.new(params[:probation])
    #if @probation_temp.started_at > @probation_temp.finished_at
    # @probation_temp.destroy
    #render('edit')
    #return
    #end
    respond_to do |format|
      if @probation.update_attributes(params[:probation])
        format.html { redirect_to @probation, :notice => 'Probations was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @probation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create
    @probation = Probation.new(params[:probation])
    @probation.user_id = session[:user].id
    respond_to do |format|
      if @probation.save
        format.html { redirect_to @probation, :notice => 'Probation was successfully created.' }
        format.json { render :json => @probation, :status => :created, :location => @probation }
      else
        format.html { render :action => "new" }
        format.json { render :json => @probation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @probation = Probation.find(params[:id])
    @daily = @probation.daily

    @daily.each do  |daily|
      @comment = daily.comment
      @comment.each do  |comment|
        comment.destroy
      end
      daily.destroy
    end

    @image = @probation.image
    @image.each do |im|
      File.delete("app/assets/images/#{im.path}")
      im.destroy
    end
    @probation.destroy

    respond_to do |format|
      format.html { redirect_to probations_url, :notice => 'Probation was successfully deleted.' }
      format.json { head :ok }
    end
  end

  def ppdf
    pdf = Prawn::Document.new
    pdf.text  "#{@probation.probation_name.upcase}", :size => 15, :style => :bold, :align => :center
    pdf.text "( #{@probation.started_at} - #{@probation.finished_at} )", :size => 10, :align => :center
    pdf.move_down(30)

    @daily_pdf.each do |daily|
      pdf.draw_text "Subject : ", :size => 13, :style => :bold, :at => [20, 650]
      pdf.text_box "#{daily.subject.capitalize}     (#{daily.created_at.to_date})", :size => 12, :at => [80, 657]
      pdf.draw_text "Content : ", :size => 13, :style => :bold, :at => [20, 630]
      pdf.text_box "#{daily.content.capitalize}", :size => 12, :at => [80, 637], :width => 500
      if daily.id != @daily_pdf.last.id
        pdf.start_new_page
      end
    end
    pdf.move_down(10)
    filename = File.join(Rails.root, "app/report", "document.pdf")
    pdf.render_file filename
    send_file filename, :filename => "document.pdf", :type => "application/pdf"
  end

end