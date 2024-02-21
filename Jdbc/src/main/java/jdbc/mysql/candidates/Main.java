package jdbc.mysql.candidates;

import java.sql.*;

public  class Main {
    public static void main(String[] args) throws SQLException{
        Candidate.getAll();
        Candidate.changeEmail(1,"carine.j@gmail.com");
        //Insert  candidates
        int id1 = Candidate.insertRow("Jane", "Smith", Date.valueOf("1982-12-31"),
                "smith.j@gmail.com","(408)-111-2222");
        var id2 = Candidate.insertRow("Jonathan","Kahn",Date.valueOf("1961-09-22"),
                "jokahn@gmail.com","(408)-111-2311");
        System.out.printf("The inserted ids are %d,%d :",id1,id2);
        int []skills= {1,2,3};
        CandidateTransaction.addRowWithSkills("John", "Doe", Date.valueOf("1990-01-04"),
                "john.d@yahoo.com", "(408) 898-5641",skills);
        Candidate.addResume(1,"/hone/vangelis/Desktop/SQL/Jdbc/src/main/resources/jdbc/mysql/candidates/resume.pdf");
        Candidate.getResume(1,"/hone/vangelis/Desktop/SQL/Jdbc/src/main/resources/jdbc/mysql/candidates/resume.pdf");

    }
}