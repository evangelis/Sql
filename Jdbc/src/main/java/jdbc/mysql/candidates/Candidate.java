package jdbc.mysql.candidates;
import java.io.*;
import java.nio.file.Paths;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Spliterator;


public class Candidate {
    public static void getAll() {
        var sql = "SELECT first_name,last_name,email FROM candidates";
        try (var conn = MySQLConnection.createConnection();
             var stmt = conn.createStatement();
             var rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                System.out.println(
                        rs.getString("first_name") + "\t" +
                                rs.getString(2) + "\t" +
                                rs.getString("email"));
            }
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        }
    }

    public static void changeEmail(int id, String email) {
        var sqlUpd = "UPDATE candidates SET email =? WHERE id =?";
        try (Connection conn = MySQLConnection.createConnection();
             var pstmt = conn.prepareStatement(sqlUpd)) {
            //Prepare data for update
            pstmt.setString(1, email);
            pstmt.setInt(2, id);
            int rowsAffected = pstmt.executeUpdate();
            System.out.println(rowsAffected + " rows affected.");
        } catch (SQLException ex) {
            System.err.println(ex.getMessage());
        }

    }
    public static int insertRow(String firstName,String lastName,Date dob,String email,String phone) throws  SQLException{
        int id = 0;
        String insSql = "INSERT INTO candidates (first_name,last_name,dob,phone,email)  VALUES(?,?,?,?,?)";
        try(var conn = MySQLConnection.createConnection();
            var pstmt = conn.prepareStatement(insSql,Statement.RETURN_GENERATED_KEYS)){
            pstmt.setString(1,firstName);
            pstmt.setString(2,lastName);
            pstmt.setDate(3,dob);
            pstmt.setString(4,phone);
            pstmt.setString(5,email);

            int rows = pstmt.executeUpdate();
            if(rows ==1){ //get candidate id
                var rs = pstmt.getGeneratedKeys();
                if(rs.next()) id = rs.getInt(1);
            }
        }
        catch (SQLException e){e.printStackTrace();}
        return  id;
    }
    public static void addResume(int cid, String fname){
        /*************************************************
         * ALTER TABLE candidates ADD COLUMN RESUME
         *         NULL AFTER email
         ***********************************************/
        var upd = "UPDATE candidates SET resume = ? WHERE id = ?";
        try(var conn = MySQLConnection.createConnection();
            var pstmt = conn.prepareStatement(upd)){
            var file = new File(fname);
            FileInputStream fin = new FileInputStream(file);
            pstmt.setBinaryStream(1,fin);
            pstmt.setInt(2,cid);
            pstmt.executeUpdate();
        }
        catch (FileNotFoundException|SQLException ex){
            ex.printStackTrace();
        }
    }
    public static void getResume(int cid,String fname) {
        var query = "SELECT resume FROM candidates WHERE id = ?";
        try (var conn = MySQLConnection.createConnection();
             var pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, cid);
            //Write the binary stream into a file
            try (var rs = pstmt.executeQuery();
                 var fout = new FileOutputStream(fname)) {
                  while (rs.next()) {
                    var bin = rs.getBinaryStream("resume");
                    byte[] buff = new byte[1024];
                    while (bin.read(buff)>0)
                        fout.write(buff);
                }

            }
            catch(IOException ioex){
                ioex.printStackTrace();

        } catch (SQLException|FileNotFoundException ex) {
            ex.printStackTrace();
        }
    }
    public static List<String> getSkills(int cid){
        //get the skills of a candidate specified by the candidate id
        var query = "{call get_candidate_skill(?)}";
        List<String> skills =new ArrayList<>();
        try(var conn = MySQLConnection.createConnection();
            CallableStatement cstmt = conn.prepareCall(query)){
            cstmt.setInt(1,cid);
            try(var rs = cstmt.executeQuery()){
                while (rs.next()){
                    skills.add(rs.getString("skill"));
                }

            }catch (SQLException ex){ex.printStackTrace();}

        }
        catch (SQLException ex){ex.printStackTrace();}
        return  skills;
    }
}