import subprocess,pathlib,json,sys,hashlib,datetime
b=pathlib.Path(__file__).parent
name,cwd,*args=sys.argv[1:]
start=datetime.datetime.now(datetime.timezone.utc).isoformat()
r=subprocess.run(args,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for s in ['stdout','stderr']:(b/(name+'.'+s)).write_bytes(getattr(r,s))
receipt={'command':args,'cwd':cwd,'exit':r.returncode,'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'streams':{s:hashlib.sha256(getattr(r,s)).hexdigest() for s in ['stdout','stderr']}}
(b/(name+'.json')).write_text(json.dumps(receipt,indent=2))
print(json.dumps(receipt))
print(r.stdout.decode('utf8',errors='replace')[-2400:].encode('ascii',errors='backslashreplace').decode())
print(r.stderr.decode('utf8',errors='replace')[-1200:].encode('ascii',errors='backslashreplace').decode())
