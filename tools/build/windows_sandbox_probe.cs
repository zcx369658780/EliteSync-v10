// Fixture-only probe. Never run Gradle, touch host ACLs, or accept host paths.
// https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Web.Script.Serialization;
using Microsoft.Win32.SafeHandles;

class Probe
{
    const string Input = @"C:\InputFixture\source.txt";
    const string Output = @"C:\ProbeOutput";
    static readonly JavaScriptSerializer Json = new JavaScriptSerializer();
    static readonly Dictionary<string, bool> Checks = new Dictionary<string, bool>();
    static readonly List<object> Operations = new List<object>();
    static StreamWriter Log;

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern SafeFileHandle CreateFile(string name, uint access, uint share, IntPtr security, uint creation, uint flags, IntPtr template);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true, EntryPoint = "MoveFileW", ExactSpelling = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool MoveFile(string source, string destination);

    internal static bool IsAccessDenied(bool succeeded, int nativeError)
    {
        return !succeeded && nativeError == 5;
    }

    static void ParentRenameDenied()
    {
        // Capture the native result rather than inferring it from an IOException message.
        // https://learn.microsoft.com/windows/win32/api/winbase/nf-winbase-movefilew
        const string name = "parent_rename_denied";
        Before(name);
        bool succeeded = MoveFile(@"C:\InputFixture", @"C:\InputFixture-renamed");
        int error = succeeded ? 0 : Marshal.GetLastWin32Error();
        Operations.Add(new { name = name, succeeded = succeeded, native_error = error });
        Checks[name] = IsAccessDenied(succeeded, error);
        if (!Checks[name]) throw new InvalidOperationException(name + " was not denied with ERROR_ACCESS_DENIED; native=" + error);
    }

    static string Hash(string path)
    {
        using (var stream = File.OpenRead(path))
        using (var sha = SHA256.Create())
            return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();
    }

    static void Before(string name)
    {
        Log.WriteLine(Json.Serialize(new { utc = DateTime.UtcNow.ToString("o"), operation = name }));
        Log.Flush();
        ((FileStream)Log.BaseStream).Flush(true);
    }

    static void AccessDenied(string name, string path, uint access, uint flags)
    {
        // https://learn.microsoft.com/windows/win32/api/fileapi/nf-fileapi-createfilew
        Before(name);
        using (var handle = CreateFile(path, access, 7, IntPtr.Zero, 3, flags, IntPtr.Zero))
        {
            int error = handle.IsInvalid ? Marshal.GetLastWin32Error() : 0;
            Operations.Add(new { name = name, succeeded = !handle.IsInvalid, native_error = error });
            Checks[name] = IsAccessDenied(!handle.IsInvalid, error);
            if (!Checks[name]) throw new InvalidOperationException(name + " was not denied with ERROR_ACCESS_DENIED");
        }
    }

    static void MutationDenied(string name, Action action)
    {
        Before(name);
        try { action(); }
        catch (UnauthorizedAccessException error)
        {
            Checks[name] = true;
            Operations.Add(new { name = name, hresult = error.HResult });
            return;
        }
        Checks[name] = false;
        throw new InvalidOperationException(name + " unexpectedly succeeded");
    }

    static object Network(AddressFamily family, string literal)
    {
        // https://learn.microsoft.com/windows/win32/winsock/windows-sockets-error-codes-2
        Before("network_" + family);
        int error = 0;
        using (var socket = new Socket(family, SocketType.Stream, ProtocolType.Tcp))
        {
            try
            {
                var pending = socket.BeginConnect(new IPEndPoint(IPAddress.Parse(literal), 9), null, null);
                using (pending.AsyncWaitHandle)
                {
                    if (!pending.AsyncWaitHandle.WaitOne(1500)) error = 10060;
                    else socket.EndConnect(pending);
                }
            }
            catch (SocketException failure) { error = failure.NativeErrorCode; }
        }
        return new { family = (int)family, native_error = error };
    }

    static int Main(string[] args)
    {
        // This check precedes all fixture operations and the guest shutdown path.
        if (Environment.UserName != "WDAGUtilityAccount" || args.Length != 1 ||
            !System.Text.RegularExpressions.Regex.IsMatch(args[0], "\\A[0-9a-f]{32}\\z")) return 20;
        var manifest = Json.Deserialize<Dictionary<string, object>>(File.ReadAllText(@"C:\Probe\manifest.json"));
        if ((string)manifest["nonce"] != args[0] ||
            Hash(Process.GetCurrentProcess().MainModule.FileName) != (string)manifest["binary_sha256"] ||
            Hash(Input) != (string)manifest["input_sha256"]) return 21;
        using (Log = new StreamWriter(new FileStream(Output + @"\operations.jsonl", FileMode.CreateNew, FileAccess.Write), new UTF8Encoding(false)))
        {
            var networks = new List<object>();
            string failure = null;
            int? failureHResult = null;
            try
            {
                Before("read_ok");
                Checks["read_ok"] = Hash(Input) == (string)manifest["input_sha256"];
                Before("output_write_ok");
                File.WriteAllText(Output + @"\owned-output.txt", args[0]);
                Checks["output_write_ok"] = File.ReadAllText(Output + @"\owned-output.txt") == args[0];
                AccessDenied("open_write_denied", Input, 0x40000000, 0);
                MutationDenied("write_content_denied", () => File.AppendAllText(Input, "probe"));
                MutationDenied("file_delete_denied", () => File.Delete(Input));
                MutationDenied("file_rename_denied", () => File.Move(Input, Input + ".renamed"));
                MutationDenied("directory_create_denied", () => Directory.CreateDirectory(@"C:\InputFixture\new-child"));
                ParentRenameDenied();
                // Only request handles: never change a DACL, owner, or child entry.
                AccessDenied("write_dac_denied", Input, 0x00040000, 0);
                AccessDenied("write_owner_denied", Input, 0x00080000, 0);
                AccessDenied("delete_child_denied", @"C:\InputFixture", 0x40, 0x02000000);
                AccessDenied("alias_write_denied", @"\\?\C:\InputFixture\source.txt", 0x40000000, 0);
                Before("network_no_active_adapter");
                bool active = false;
                foreach (var adapter in NetworkInterface.GetAllNetworkInterfaces())
                    if (adapter.NetworkInterfaceType != NetworkInterfaceType.Loopback && adapter.OperationalStatus == OperationalStatus.Up) active = true;
                Checks["network_no_active_adapter"] = !active;
                networks.Add(Network(AddressFamily.InterNetwork, "192.0.2.1"));
                networks.Add(Network(AddressFamily.InterNetworkV6, "2001:db8::1"));
            }
            catch (Exception error) { failure = error.GetType().FullName + ": " + error.Message; failureHResult = error.HResult; }
            var process = Process.GetCurrentProcess();
            var result = new { schema = 1, nonce = args[0], username = Environment.UserName,
                input_sha256 = Hash(Input), binary_sha256 = Hash(process.MainModule.FileName),
                pid = process.Id, creation_utc = process.StartTime.ToUniversalTime().ToString("o"),
                checks = Checks, operations = Operations, network = networks, failure = failure,
                failure_hresult = failureHResult,
                shutdown_requested = true };
            Before("write_receipt_and_request_guest_shutdown");
            using (var stream = new FileStream(Output + @"\result.pending", FileMode.CreateNew, FileAccess.Write))
            {
                var bytes = Encoding.UTF8.GetBytes(Json.Serialize(result));
                stream.Write(bytes, 0, bytes.Length);
                stream.Flush(true);
            }
            File.Move(Output + @"\result.pending", Output + @"\result.json");
        }
        // The identity, nonce, binary and input checks above gate this guest-only action.
        Process.Start(new ProcessStartInfo(Path.Combine(Environment.SystemDirectory, "shutdown.exe"), "/s /t 3") { UseShellExecute = false, CreateNoWindow = true });
        return 0;
    }
}
