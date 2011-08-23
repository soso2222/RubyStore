class Group
  include MongoMapper::Document

  key :name, String
  key :role_ids, Array
  many :roles, :in => :role_ids

end
