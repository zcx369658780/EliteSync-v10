import sys,subprocess,json,pathlib,datetime
E=pathlib.Path(__file__).parent;label=sys.argv[1]
assert not (E/(label+'.command.json')).exists()
r=subprocess.run(sys.argv[2:],capture_output=True)
(E/(label+'.stdout')).write_bytes(r.stdout);(E/(label+'.stderr')).write_bytes(r.stderr)
(E/(label+'.command.json')).write_text(json.dumps({'argv':sys.argv[2:],'cwd':str(pathlib.Path.cwd()),'exit':r.returncode,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}))
print(json.dumps({'label':label,'exit':r.returncode}));sys.exit(r.returncode)
