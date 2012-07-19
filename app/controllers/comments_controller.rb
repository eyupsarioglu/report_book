class CommentsController < ApplicationController
  def create
    @daily = Daily.find(params[:daily_id])
    @comment = @daily.comment.new(params[:comment])

    #@probation.id = @daily.probation_id
    #if @probation.started_at > @probation.finished_at
    #  render('new')
    #  return
    #end
    respond_to do |format|
      if@comment.save
        format.html { redirect_to [@daily.probation, @daily], :notice => 'Comment was successfully created.' }
        format.json { render :json => [@daily.probation, @daily], :status => :created, :location => [@daily.probation, @daily] }
      else
        format.html { render :action => "new" }
        format.json { render :json => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
end
