package jdbc.mysql.books;
import javax.print.attribute.PrintServiceAttributeSet;
import java.sql.*;

public class BooksTransaction{
    public static void update() throws SQLException{
        String query = "SELECT * FROM books";
        Connection conn =null;
        try{
            conn = MySQLConnection.createConnection();
            if (conn == null) return;
            conn.setAutoCommit(false);
        }catch (SQLException ex){ex.printStackTrace();}
        try(//var conn = MySQLConnection.createConnection();
            var stmt = conn.createStatement(
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            var rs = stmt.executeQuery(query)){
            conn.setAutoCommit(false); // Disable auto-commit
            rs.last();
            System.out.println(rs.getRow()+":\t"+rs.getInt(1)+"\t"+rs.getString(2)+"\t"+
                    rs.getString("title")+ "\t"+rs.getDouble("price")+"\t"+
                    rs.getInt("qty"));
            System.out.println("Updating last row (setting price =87.30,quantity =103");
            rs.updateInt("qty",103);
            rs.updateDouble("price",87.30);
            rs.updateRow();//updates the row in the data source
            System.out.println("Delete first row");
            rs.first();
            System.out.println(rs.getRow()+":\t"+rs.getInt(1)+"\t"+rs.getString(2)+"\t"+
                    rs.getString("title")+ "\t"+rs.getDouble("price")+"\t"+
                    rs.getInt("qty"));
            rs.deleteRow();
            System.out.println("Insert a row ");
            rs.moveToInsertRow();
            rs.updateInt(1,8001);
            rs.updateString(2,"Even More Programming");
            rs.updateString(3,"Kumar");
            rs.updateDouble(4,68.80);
            rs.updateInt("qty",89);
            rs.insertRow();
            rs.absolute(3);
            System.out.println("Absolute row 3");
            System.out.println(rs.getRow()+":\t"+rs.getInt(1)+"\t"+rs.getString(2)+"\t"+
                    rs.getString("title")+ "\t"+rs.getDouble("price")+"\t"+
                    rs.getInt("qty"));
            System.out.println("Relative row -1");
            System.out.println(rs.getRow()+":\t"+rs.getInt(1)+"\t"+rs.getString(2)+"\t"+
                    rs.getString("title")+ "\t"+rs.getDouble("price")+"\t"+
                    rs.getInt("qty"));
            rs.beforeFirst();
            conn.commit();
            System.out.println("The SQL query is "+ query);
            while(rs.next()) {
                System.out.println(rs.getRow() + ":\t" + rs.getInt(1) + "\t" + rs.getString(2) + "\t" +
                        rs.getString("title") + "\t" + rs.getDouble("price") + "\t" +
                        rs.getInt("qty"));

            }
        }
        catch (SQLException exception){
            conn.rollback();
            System.err.println(exception.getMessage());
        }
        finally {
            try {
                if (conn != null) conn.close();
            }catch (SQLException ex){ex.printStackTrace();}
        }

    }
    public static void getMetadata() throws  SQLException{
        try(var conn = MySQLConnection.createConnection();){
            DatabaseMetaData dbmd = conn.getMetaData();
            System.out.println("ResultSet Type support :");
            System.out.println(dbmd.supportsResultSetType(ResultSet.TYPE_FORWARD_ONLY));
            System.out.println(dbmd.supportsResultSetType(ResultSet.TYPE_SCROLL_INSENSITIVE));
            System.out.println(dbmd.supportsResultSetType(ResultSet.TYPE_SCROLL_SENSITIVE));

            System.out.println("ResultSet Concurrency support");
            System.out.println(dbmd.supportsResultSetType(ResultSet.CONCUR_READ_ONLY));
            System.out.println(dbmd.supportsResultSetType(ResultSet.CONCUR_UPDATABLE));

            System.out.println("ResultSet cursor Holdability support");
            System.out.println(dbmd.supportsResultSetType(ResultSet.CLOSE_CURSORS_AT_COMMIT));
            System.out.println(dbmd.supportsResultSetType(ResultSet.HOLD_CURSORS_OVER_COMMIT));


        }
        catch (SQLException ex){ex.printStackTrace();}

    }
}
