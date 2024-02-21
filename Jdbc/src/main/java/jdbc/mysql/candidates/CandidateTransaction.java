package jdbc.mysql.candidates;
import javax.management.StandardEmitterMBean;
import java.sql.*;
public class CandidateTransaction {
    public static void addRowWithSkills(String firstName, String lastName, Date dob,String email,
                                        String phone,int[] skills) throws SQLException{
        Connection conn;
        PreparedStatement pstmt =null, passignment = null;
        String insertSql = "INSERT INTO candidates(first_name, last_name, dob, phone, email)" +
                " VALUES (?, ?, ?, ?, ?)";
        ResultSet rs =null;
        try{
            conn = MySQLConnection.createConnection();
            if(conn == null) return ;
            conn.setAutoCommit(false);
            pstmt= conn.prepareStatement(insertSql,Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1,firstName);
            pstmt.setString(2,lastName);
            pstmt.setDate(3,dob);
            pstmt.setString(4,phone);
            pstmt.setString(5,email);

            int rows = pstmt.executeUpdate();
            if(rows ==1){
                rs = pstmt.getGeneratedKeys();
                int candidateId = (rs.next())? rs.getInt(1) : 0;
                String sqlPivot = "INSERT INTO candidate_skills(candidate_id,skill_id) " +
                        "VALUES (?,?)";
                passignment = conn.prepareStatement(sqlPivot);
                for(int  sid :skills){
                    passignment.setInt(1,candidateId);
                    passignment.setInt(2,sid);
                    passignment.executeUpdate();
                }
                conn.commit();
            }
            else{conn.rollback();}

        }
        catch (SQLException ex){
            try{
                conn.rollback();
            }
            catch(SQLException e) {
                ex.printStackTrace();
            }
            System.err.println(ex.getMessage());
        }
        finally {
            try{
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
                if(passignment != null) passignment.close();
                if(conn != null) conn.close();
            }
            catch (SQLException e){
                System.err.println(e.getMessage());
            }
        }

    }
}