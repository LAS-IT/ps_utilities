# UPDATE A STUDENT ACCOUNT
data = { id: 7337, student_id: 555807, email: "joey@las.ch",
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
}
kids = ps.run(command: :update_student, params: {student: data })

# UPDATE SEVERAL STUDENT ACCOUNTS
data = [
  { id: 7337, student_id: 555807, email: "joey@las.ch",
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
  },,
  { id: 7338, student_id: 555808, email: "jack@las.ch",
    u_students_extension: { student_email: "jack@las.ch", preferredname: "jack"},
    u_studentsuserfields: { transcriptaddrline1: "A Rd.",
                            transcriptaddrzip: "1859", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Aigle",transcriptaddrcountry: "DE"}
  }
]
kids = ps.run(command: :update_students, params: {students: data })
