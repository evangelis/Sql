package jdbc.mysql.candidates;
import java.io.InputStream;
import java.io.IOException;
import java.util.Properties;

public class DatabaseConfig {
    private static final Properties props = new Properties();
    private static final String path =
            "/home/vangelis/Desktop/SQL/Jdbc/src/main/resources/jdbc/mysql/candidates/config.properties";
    static {
        try(InputStream in = DatabaseConfig.class.getClassLoader()
                .getResourceAsStream(path)){
            if(in == null) {
            System.err.println("Sorry,unable to find configuration file");
            System.exit(1);
        }
            props.load(in);

        }catch (IOException ex){ex.printStackTrace();}

    }
    public static String getDbUrl(){
        return props.getProperty("db.url");
    }
    public static String getDbUser(){
        return props.getProperty("db.user");
    }
    public static String getDbPassword(){
        return props.getProperty("db.password");
    }
}