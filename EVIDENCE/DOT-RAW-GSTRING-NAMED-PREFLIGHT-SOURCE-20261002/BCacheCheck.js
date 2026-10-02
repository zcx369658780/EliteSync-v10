const inv = load("rawGStringInvocation");
const b = load("rawGStringB");
if (inv.exit_code !== 0 || b.exit_code !== 0) throw Error("NATIVE_EXIT");
const receipt = JSON.parse(inv.output.trim());
const disk = JSON.parse(b.output.trim());
if (receipt.Result !== "DIAGNOSTIC_CAPTURE_COMPLETE") throw Error("NATIVE_RESULT");
for (const [name, prefix] of [["stdout.bin","Stdout"],["stderr.bin","Stderr"],["probe-wrapper.json","Wrapper"]]) {
  if (receipt[prefix+"Bytes"] !== disk.Facts[name].Bytes ||
      receipt[prefix+"SHA256"] !== disk.Facts[name].SHA256) throw Error("NATIVE_DISK_IDENTITY");
}
for (const k of ["ProcessStartAttempt","CandidateInvocation","CandidateInvocationAttempt","CandidateParseClassLoad","CandidateSourceRead","FourteenCaseInvocation","InvokeOutcome","RuntimeReady"]) {
  if (receipt[k] !== disk.Wrapper[k]) throw Error("NATIVE_WRAPPER_FIELD");
}
text({Result:"B_ORIGINAL_NATIVE_AND_DISK_MATCH",CandidateAcceptance:"NOT_GRANTED"});
