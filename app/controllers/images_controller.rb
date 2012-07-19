class ImagesController < ApplicationController
  def create
    @probation = Probation.find(params[:probation_id])
    @image = @probation.image.create(:name => nil, :path =>  params[:image][:path].original_filename)

    params[:image][:name] =  "#{@image.id}" + params[:image][:path].original_filename

    if @image.id != nil
      Image.save(params[:image])
    end

    params[:image][:path] = params[:image][:name]
    #@probation.id = @daily.probation_id
    #if @probation.started_at > @probation.finished_at
    #  render('new')
    #  return
    #end
    respond_to do |format|
      if@image.update_attributes(params[:image])


        format.html { redirect_to @image.probation, :notice => 'Image was successfully uploaded.' }
        format.json { render :json => @image.probation, :status => :created, :location => @image.probation }
      else
        format.html { redirect_to @image.probation, :notice => 'MUST BE JPEG, JPG, PNG' }
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end

  end

  def destroy
    @image = Image.find(params[:id])
    @probation = @image.probation
    File.delete("app/assets/images/#{@image.path}")
    @image.destroy

    respond_to do |format|
      format.html { redirect_to @probation, :notice => 'Daily was successfully deleted.' }
      format.json { head :ok }
    end
  end

end
