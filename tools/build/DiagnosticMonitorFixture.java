// Guest-only Java process tree for supervisor qualification; never Gradle.
import java.net.*;
import java.nio.file.*;
public class DiagnosticMonitorFixture {
    public static void main(String[] args) throws Exception {
        if (!"WDAGUtilityAccount".equals(System.getProperty("user.name"))) System.exit(20);
        if (args.length==0) {
            new ProcessBuilder("C:/Inputs/Jdk/bin/javaw.exe","-cp","C:/Probe","DiagnosticMonitorFixture","leaf").inheritIO().start();
            Thread.sleep(30000);
        } else {
            try (ServerSocket good=new ServerSocket(0,1,InetAddress.getLoopbackAddress())) {
                Files.writeString(Paths.get("C:/ProbeOutput/fixture-positive.txt"),Integer.toString(good.getLocalPort()),StandardOpenOption.CREATE_NEW);
                Thread.sleep(5000);
                try (ServerSocket bad=new ServerSocket(0,1,InetAddress.getByName("0.0.0.0"))) {Thread.sleep(30000);}
            }
        }
    }
}
