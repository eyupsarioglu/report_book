class Image < ActiveRecord::Base
  attr_accessible :name, :path
  validates :path, :presence => true, :format => { :with => %r{.*\.(jpeg|png|jpg)} }
  belongs_to :probation


  def self.save(upload)
    name = upload[:name]
    directory = "app/assets/images"
    # create the file path
    path =  File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['path'].read) }
  end
end
