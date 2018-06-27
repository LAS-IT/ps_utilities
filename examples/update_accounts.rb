data = [
  { id: 7337, student_id: 555807, email: "joey@las.ch",
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrcity: "Bex", 
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcountry: "CH", transcriptaddrline2: "CP 108"} }
]
kids = ps.run(command: :update_students, params: {students: data })
