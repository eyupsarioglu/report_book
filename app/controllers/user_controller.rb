class UserController < ApplicationController
  before_filter :authenticate_user!
  before_filter 'kntrl', :only => [:index, :edit, :update]
  before_filter 'kontrl_dstry', :only => [:destroy]

  def kntrl
     if current_user.role != "admin"
       redirect_to probations_path
     end
  end

  def kontrl_dstry
    if current_user.role != "admin" and current_user.id != session[:user].id
      redirect_to probations_path
    end
  end

  def index

    @user_all = User.where('id != ?', current_user.id).paginate(:page => params[:page], :per_page => 15).order("name ASC")
  end

  def show
      session[:user] = User.find(params[:id])
  end

  def edit

    @user_edit = User.find(session[:user].id)
  end

  def update
    @user_edit = User.find(session[:user].id)
    respond_to do |format|
      if @user_edit.update_attributes(params[:user])
        format.html { redirect_to user_path(@user_edit), :notice => 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user_edit.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    @user_del = User.find(session[:user].id)
    @probation = @user_del.probation
    @probation.each do |pro|
      @daily = pro.daily
      @daily.each do  |daily|
        @comment = daily.comment
        @comment.each do  |comment|
          comment.destroy
        end
        daily.destroy
      end

      @image = pro.image
      @image.each do |im|
        File.delete("app/assets/images/#{im.path}")
        im.destroy
      end
      pro.destroy
    end
    @user_del.destroy
    respond_to do |format|
      format.html { redirect_to user_index_path, :notice => 'User was successfully deleted.' }
      format.json { head :ok }
    end
  end
end
 #