kids = ps.run(command: :get_all_matching_students, params: {student_id: "1*",last_name: "BAS*"})
# { :students=> [
#     { "id"=>1718, "local_id"=>1917, "student_username"=>"bbbbbb917",
#       "name"=>{"first_name"=>"Aaaaaaa", "last_name"=>"Bbbbbbbb"}
#     },
#     { "id"=>2612, "local_id"=>101971, "student_username"=>"bbbbbb871",
#       "name"=>{"first_name"=>"Dddddd", "last_name"=>"CCCCCCCc"}
#     },
#     { "id"=>2613, "local_id"=>101972, "student_username"=>"bastova972",
#       "name"=>{"first_name"=>"Aaaaaa", "last_name"=>"DDDDDDDD"}
#     },
#     { "id"=>6862, "local_id"=>115706, "student_username"=>"bastost706",
#       "name"=>{"first_name"=>"TTttttt", "last_name"=>"BBB CCC PPP"}
#     }
#   ]
# }
kids = ps.run(command: :get_all_active_students, params: {student_id: "1*",last_name: "BA*"})
kids = ps.run(command: :get_all_active_students)
kids = ps.run(command: :get_one_student, params: {id: 1718})
