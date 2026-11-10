// Pure result-classification tests; do not invoke guest Main or native file APIs.
using System;

class ProbeNativeResultTests
{
    static int Main()
    {
        if (!Probe.IsAccessDenied(false, 5)) throw new Exception("Explicit access denial rejected");
        if (Probe.IsAccessDenied(true, 5)) throw new Exception("Stale error on success accepted");
        foreach (int error in new int[] { 0, 2, 3, 32, 87 })
            if (Probe.IsAccessDenied(false, error)) throw new Exception("Non-denial accepted: " + error);
        Console.WriteLine("7 native result classification cases passed; no native APIs invoked.");
        return 0;
    }
}
