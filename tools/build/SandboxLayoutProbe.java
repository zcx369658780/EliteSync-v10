// Filesystem assembly/identity checks only. Never load Gradle classes or run tools.
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.security.MessageDigest;
import java.util.*;

public class SandboxLayoutProbe {
    static final Path OUT=Paths.get("C:/ProbeOutput"), WORK=Paths.get("C:/BuildWork");
    static Properties config=new Properties();
    static String nonce;
    static String quote(String value) {
        StringBuilder out=new StringBuilder("\"");
        for(char c:value.toCharArray()) {
            if(c=='"'||c=='\\')out.append('\\').append(c);
            else if(c<32)out.append(String.format("\\u%04x",(int)c));else out.append(c);
        }
        return out.append('"').toString();
    }
    static String json(Object value) {
        if(value==null)return "null";
        if(value instanceof Boolean||value instanceof Number)return value.toString();
        if(value instanceof Map) {
            List<String> fields=new ArrayList<>();
            for(Object raw:((Map<?,?>)value).entrySet()) {Map.Entry<?,?> e=(Map.Entry<?,?>)raw;fields.add(quote(e.getKey().toString())+":"+json(e.getValue()));}
            return "{"+String.join(",",fields)+"}";
        }
        if(value instanceof List) {List<String> items=new ArrayList<>();for(Object item:(List<?>)value)items.add(json(item));return "["+String.join(",",items)+"]";}
        return quote(value.toString());
    }
    static void write(String name,Object value) throws Exception {
        Path pending=OUT.resolve(name+".pending"), target=OUT.resolve(name+".json");
        Files.writeString(pending,json(value),StandardCharsets.UTF_8,StandardOpenOption.CREATE_NEW);
        try(java.nio.channels.FileChannel channel=java.nio.channels.FileChannel.open(pending,StandardOpenOption.WRITE)){channel.force(true);}
        Files.move(pending,target);
    }
    static String sha(Path path) throws Exception {
        MessageDigest md=MessageDigest.getInstance("SHA-256");
        try(InputStream stream=Files.newInputStream(path)){byte[] bytes=new byte[131072];int n;while((n=stream.read(bytes))!=-1)md.update(bytes,0,n);}
        StringBuilder result=new StringBuilder();for(byte b:md.digest())result.append(String.format("%02x",b&255));return result.toString();
    }
    static Path relative(Path root,String text) throws Exception {
        Path part=Paths.get(text);
        if(part.isAbsolute()||part.toString().contains(".."))throw new IOException("unsafe relative path");
        Path path=root.resolve(part).normalize();if(!path.startsWith(root))throw new IOException("path escape");return path;
    }
    static Map<String,Object> traits(Path path) throws Exception {
        Map<String,Object> result=new LinkedHashMap<>();
        BasicFileAttributes attributes=Files.readAttributes(path,BasicFileAttributes.class,LinkOption.NOFOLLOW_LINKS);
        Path real=path.toRealPath(); boolean ancestorsClean=true;
        for(Path p=path;p!=null;p=p.getParent()) {
            BasicFileAttributes a=Files.readAttributes(p,BasicFileAttributes.class,LinkOption.NOFOLLOW_LINKS);
            if(Files.isSymbolicLink(p)||a.isOther())ancestorsClean=false;
        }
        result.put("path",path.toString());result.put("real",real.toString());
        result.put("symbolic_link",Files.isSymbolicLink(path));result.put("other",attributes.isOther());
        result.put("directory",attributes.isDirectory());result.put("ancestors_clean",ancestorsClean);
        result.put("canonical_equal",path.isAbsolute()&&path.normalize().equals(path)&&real.equals(path));return result;
    }
    static int files(String group,Path input,Path target) throws Exception {
        int count=Integer.parseInt(config.getProperty(group+".count"));
        for(int i=0;i<count;i++) {
            String key=group+"."+i;String name=config.getProperty(key+".relative");Path source=relative(input,name);
            if(!sha(source).equals(config.getProperty(key+".sha256")))throw new IOException("input drift: "+group+" "+i);
            if(target!=null) {
                Path dest=relative(target,name);Files.createDirectories(dest.getParent());Files.copy(source,dest);
                if(!sha(dest).equals(config.getProperty(key+".sha256")))throw new IOException("copy drift");
            }
            if(i%100==0)Files.writeString(OUT.resolve("progress.jsonl"),json(Map.of("group",group,"checked",i,"nonce",nonce))+"\n",StandardCharsets.UTF_8,StandardOpenOption.CREATE,StandardOpenOption.APPEND);
        }
        return count;
    }
    static void ownedWrite(Path directory) throws Exception {
        if(!directory.startsWith(WORK))throw new IOException("write scope");Files.createDirectories(directory);
        Path file=directory.resolve("owned-layout-check.txt");Files.writeString(file,nonce,StandardOpenOption.CREATE_NEW);
        if(!Files.readString(file).equals(nonce))throw new IOException("private write mismatch");
    }
    public static void main(String[] args) throws Exception {
        if(!"WDAGUtilityAccount".equals(System.getProperty("user.name"))||args.length!=1||!args[0].matches("[0-9a-f]{32}"))System.exit(20);
        nonce=args[0];try(Reader reader=Files.newBufferedReader(Paths.get("C:/Probe/layout.properties"),StandardCharsets.UTF_8)){config.load(reader);}
        if(!nonce.equals(config.getProperty("nonce")))System.exit(21);
        Map<String,Object> result=new LinkedHashMap<>();result.put("nonce",nonce);result.put("username",System.getProperty("user.name"));
        result.put("java_version",System.getProperty("java.version"));result.put("os_version",System.getProperty("os.version"));result.put("os_name",System.getProperty("os.name"));
        try {
            if(Files.exists(WORK))throw new IOException("private work root already exists");Files.createDirectory(WORK);
            int product=files("product",Paths.get("C:/Inputs/Product"),WORK.resolve("Project"));
            int tooling=files("tooling",Paths.get("C:/Inputs/ToolingSnapshot"),WORK.resolve("Tooling"));
            int nativeFiles=files("native",Paths.get("C:/Inputs/Pub"),null);
            int seed=files("seed",Paths.get("C:/Inputs/DependencyCache"),null);
            Path module=WORK.resolve("Project/apps/flutter_elitesync_module/.android");
            int nativeCount=Integer.parseInt(config.getProperty("plugins.count"));
            for(int i=0;i<nativeCount;i++)ownedWrite(module.resolve("plugins_build_output/"+config.getProperty("plugins."+i)));
            Path cmake=WORK.resolve("state/cmake/jni");ownedWrite(cmake);ownedWrite(WORK.resolve("GradleHome"));
            ownedWrite(WORK.resolve("state/project-cache"));ownedWrite(WORK.resolve("Tooling/packages/flutter_tools/gradle/build"));
            ownedWrite(WORK.resolve("Tooling/packages/flutter_tools/gradle/.gradle"));
            if(Files.exists(Paths.get("C:/Inputs/Pub/jni/android/.cxx")))throw new IOException("old jni generated cache visible");
            List<Object> paths=new ArrayList<>();
            for(Path path:new Path[]{Paths.get("C:/Inputs/Flutter"),Paths.get("C:/Inputs/Flutter/packages/flutter_tools/gradle"),
                Paths.get("C:/Inputs/DependencyCache/modules-2"),Paths.get("C:/Inputs/Pub/jni/android"),
                module,WORK.resolve("Tooling/packages/flutter_tools/gradle"),cmake,WORK.resolve("GradleHome")})paths.add(traits(path));
            boolean guardEqual=Paths.get("C:/Inputs/Flutter/packages/flutter_tools/gradle").toRealPath().equals(WORK.resolve("Tooling/packages/flutter_tools/gradle").toRealPath());
            result.put("product_files",product);result.put("tooling_files",tooling);result.put("native_files",nativeFiles);result.put("seed_files",seed);
            result.put("native_plugins",nativeCount);result.put("private_writes",nativeCount+5);result.put("path_traits",paths);
            result.put("original_guard_tooling_path_equal",guardEqual);result.put("old_jni_generated_cache_visible",false);
            result.put("guest_work_usable_bytes",Files.getFileStore(WORK).getUsableSpace());result.put("failure",null);
        }catch(Exception error){result.put("failure",error.getClass().getName()+": "+error.getMessage());}
        result.put("gradle_starts",0);result.put("G2",false);result.put("gradle_index_parse",false);result.put("agp_override_consumed",false);
        write("layout-result",result);
        if(result.get("failure")!=null)System.exit(1);
    }
}
