"""Independent Linux process: no successful authority pulse => kill owned media.

Only anonymous pipe FDs and owned process IDs cross this boundary. No bind mount,
HTTP, credentials, asyncio event loop, or diagnostic output is required to stop.
"""
import os,select,signal,sys,time
fd,parent,sfu=map(int,sys.argv[1:]);last=time.monotonic()
while True:
    readable,_,_=select.select([fd],[],[],.05)
    if readable:
        data=os.read(fd,4096)
        if data:last=time.monotonic()
        else:break
    if time.monotonic()-last>3.5:break
try:os.kill(sfu,signal.SIGKILL)
except ProcessLookupError:pass
# Linux PID 1 ignores unhandled fatal signals from its own namespace. The
# gateway installs a SIGTERM handler; media has already been killed above.
try:os.kill(parent,signal.SIGTERM)
except ProcessLookupError:pass
os._exit(1)
