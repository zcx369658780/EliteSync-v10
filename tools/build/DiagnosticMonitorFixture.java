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
                Path churn=Paths.get("C:/BuildWork/disk-churn");Files.createDirectory(churn);
                long end=System.nanoTime()+5_000_000_000L;int operations=0;
                while(System.nanoTime()<end) {
                    Path temporary=Files.createTempDirectory(churn,"pending-");
                    Files.writeString(temporary.resolve("sample.bin"),"owned transient metadata");
                    Path renamed=churn.resolve("renamed-"+operations);
                    Files.move(temporary,renamed,StandardCopyOption.ATOMIC_MOVE);
                    Files.delete(renamed.resolve("sample.bin"));Files.delete(renamed);operations++;
                    Thread.sleep(2);
                }
                Files.writeString(Paths.get("C:/ProbeOutput/fixture-churn-operations.txt"),Integer.toString(operations),StandardOpenOption.CREATE_NEW);
                try (ServerSocket bad=new ServerSocket(0,1,InetAddress.getByName("0.0.0.0"))) {Thread.sleep(30000);}
            }
        }
    }
}
