# MAKE A STUDENT ACCOUNT
data = {
  student_id: 210987, first_name: "Joe", last_name: "Jackson",
  email: "joey@las.ch", entry_date: "2018-05-30", exit_date: "2018-08-15",
  school_number: 1, grade_level: 9,
  u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
  u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                          transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                          transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
}
kids = ps.run(command: :create_student, params: {students: [data] })

# MAKE SEVERAL STUDENT ACCOUNTS
data = [
  { student_id: 210987, first_name: "Joe", last_name: "Jackson",
    email: "joey@las.ch", entry_date: "2018-05-30", exit_date: "2018-08-15",
    school_number: 1, grade_level: 9,
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
  },
  { student_id: 210988, first_name: "Jack", last_name: "Jackson",
    email: "jacky@las.ch", entry_date: "2018-05-30", exit_date: "2018-08-15",
    school_number: 33, grade_level: 11,
    u_students_extension: { student_email: "jack@las.ch", preferredname: "jack"},
    u_studentsuserfields: { transcriptaddrline1: "A Rd.",
                            transcriptaddrzip: "1859", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Aigle",transcriptaddrcountry: "DE"}
  }
]
kids = ps.run(command: :create_students, params: {students: data })
