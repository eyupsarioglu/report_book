class HomeController < ApplicationController
  def index
    session[:url] = "home"
    @daily = Daily.where(:status => true).paginate(:page => params[:page], :per_page => 20).order("created_at DESC")
  end

  def show
    @daily = Daily.find(params[:id])
    @comment = @daily.comment.paginate(:page => params[:page], :per_page => 5).order("created_at DESC")
    respond_to do |format|
      format.html # show.html.erb
      format.pdf  { ppdf(@daily) }
    end
  end

  def ppdf(daily)
    pdf = Prawn::Document.new
    pdf.text  "#{daily.probation.probation_name.upcase}", :size => 15, :style => :bold, :align => :center
    pdf.text "( #{daily.probation.started_at} - #{daily.probation.finished_at} )", :size => 10, :align => :center
    pdf.move_down(30)


      pdf.draw_text "Subject : ", :size => 13, :style => :bold, :at => [20, 650]
      pdf.text_box "#{daily.subject.capitalize}     (#{daily.created_at.to_date})", :size => 12, :at => [80, 657]
      pdf.draw_text "Content : ", :size => 13, :style => :bold, :at => [20, 630]
      pdf.text_box "#{daily.content.capitalize}", :size => 12, :at => [80, 637], :width => 500

    pdf.move_down(10)
    filename = File.join(Rails.root, "app/report", "document.pdf")
    pdf.render_file filename
    send_file filename, :filename => "document.pdf", :type => "application/pdf"
  end

end
