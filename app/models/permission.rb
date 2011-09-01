class Permission
    include MongoMapper::Document

    key :controller, String
    key :method, String
    key :role_ids, Array
    many :roles, :in => :role_ids
end