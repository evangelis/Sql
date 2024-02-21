package jdbc.mysql.candidates;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class MySQLConnection {
    public static Connection createConnection() throws  SQLException{
        try{
            //Register JDBC drive
            //Get db credentials from the DatabaseConfig c
            //Open a connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            var jdbcUrl = DatabaseConfig.getDbUrl();
            var usr = DatabaseConfig.getDbUser();
            var pwd = DatabaseConfig.getDbPassword();
            return DriverManager.getConnection(jdbcUrl,usr,pwd);
        }
        catch (SQLException|ClassNotFoundException ex){
            System.err.println(ex.getMessage());
            return null;
        }
    }
}