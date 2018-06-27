

def las_db_extensions(kid)
  # # attribs = {}
  # # attribs["_table_extension"] = []
  # attribs = { "_table_extension" => [] }
  # if kid[:email] or kid[:preferred_name]
  #   db_extensions =
  #     { "recordFound"=>false,
  #       "name"=>"u_students_extension",
  #       "_field"=> [ ]
  #     }
  #   if kid[:email]
  #     db_extensions["_field"] << {"name"=>"student_email", "type"=>"String", "value"=>"#{kid[:email]}"}
  #   end
  #   if kid[:preferredname]
  #     db_extensions["_field"] << {"name"=>"preferredname", "type"=>"String", "value"=>"#{kid[:preferredname]}"}
  #   end
  #   if kid[:preferred_name]
  #     db_extensions["_field"] << {"name"=>"preferredname", "type"=>"String", "value"=>"#{kid[:preferred_name]}"}
  #   end
  #   attribs["_table_extension"] << db_extensions
  #   # { "recordFound"=>false,
  #   #   "name"=>"u_students_extension",
  #   #   "_field"=> [
  #   #     {"name"=>"preferredname", "type"=>"String", "value"=>"Niko"},
  #   #     {"name"=>"student_email", "type"=>"String", "value"=>"#{kid[:email]}"}
  #   #   ]
  #   # }
  # end
  end
  pp attribs
  attribs
end
# to inject into _extension_data
# attribs["_extension_data"] = { "_table_extension" => [] }
# attribs["_extension_data"]["_table_extension"] << {
#   "recordFound"=>false,
#   "name"=>"u_students_extension",
#   "_field"=> [
#     {"name"=>"preferredname", "type"=>"String", "value"=>"Jimmy"},
#     {"name"=>"student_email", "type"=>"String", "value"=>"bbaaccdd@las.ch"}
#   ]
# }
