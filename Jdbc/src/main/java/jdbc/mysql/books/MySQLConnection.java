package jdbc.mysql.books;
import java.io.FileNotFoundException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
public class MySQLConnection {
    private static Properties  connetionProperties(){
        var path =
                "/home/vangelis/Desktop/SQL/Jdbc/src/main/resources/jdbc/mysql/books/config.properties";
        //read a resource file from the classpath
        final Properties props = new Properties();
            try {
                InputStream in = MySQLConnection.class.getClassLoader()
                        .getResourceAsStream(path);
                if (in == null) {
                    System.err.println("Unable to find configuration file");
                    System.exit(1);
                }
                props.load(in);
            }
            catch (IOException ex) {
                ex.printStackTrace();
                return null;
            }
            return props;
    }
    public static Connection createConnection() throws SQLException{
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            final Properties properties = connetionProperties();
            var jdbcUrl = properties.getProperty("db.url");
            var usr = properties.getProperty("db.user");
            var pwd = properties.getProperty("db.password");
            return DriverManager.getConnection(jdbcUrl,usr,pwd);
        }
        catch (SQLException|ClassNotFoundException ex){
            ex.printStackTrace();
            return null;
        }
    }
}