"""Inject distinct fictional tones into owned Android microphones; capture virtual speaker output.
No host microphone/camera is opened. WAVs stay LOCAL_ONLY.
"""
import pathlib,sys,time,math,struct,threading,wave,json,importlib.util
q=pathlib.Path(sys.argv[1]);duration=float(sys.argv[2]);label=sys.argv[3];capture_enabled='--capture' in sys.argv[4:]
spec=importlib.util.spec_from_file_location('owned_device',pathlib.Path(__file__).with_name('device-control.py'))
device=importlib.util.module_from_spec(spec);spec.loader.exec_module(device)
from google.protobuf.empty_pb2 import Empty
stop=threading.Event();started=time.time();receipts=[];lock=threading.Lock()

def inject(suffix,frequency):
    stub,headers=device.client(suffix);sample_rate=48000;count=960
    mode=device.pb.AudioFormat.MODE_UNSPECIFIED if '--buffered' in sys.argv[4:] else device.pb.AudioFormat.MODE_REAL_TIME
    fmt=device.pb.AudioFormat(samplingRate=sample_rate,channels=device.pb.AudioFormat.Mono,format=device.pb.AudioFormat.AUD_FMT_S16,mode=mode)
    def packets():
        position=0
        while not stop.is_set():
            pcm=struct.pack('<'+'h'*count,*[int(6500*math.sin(2*math.pi*frequency*(position+i)/sample_rate)) for i in range(count)])
            position+=count
            yield device.pb.AudioPacket(format=fmt,timestamp=int(time.time()*1e6),audio=pcm)
            time.sleep(.02)
    try:
        stub.injectAudio(packets(),metadata=headers,timeout=duration+3)
        result='completed'
    except Exception as e:result={'type':type(e).__name__,'code':str(e.code()) if hasattr(e,'code') else None,'detail':e.details() if hasattr(e,'details') else ''}
    with lock:receipts.append({'side':suffix,'source_hz':frequency,'injection':result})

def capture(suffix):
    stub,headers=device.client(suffix)
    fmt=device.pb.AudioFormat(samplingRate=48000,channels=device.pb.AudioFormat.Mono,format=device.pb.AudioFormat.AUD_FMT_S16,mode=device.pb.AudioFormat.MODE_REAL_TIME)
    stream=stub.streamAudio(fmt,metadata=headers,timeout=duration+2)
    metrics=[]
    with wave.open(str(q/(label+'-'+suffix+'-speaker.wav')),'wb') as out:
        out.setnchannels(1);out.setsampwidth(2);out.setframerate(48000)
        try:
            for packet in stream:
                if stop.is_set():break
                out.writeframes(packet.audio)
                samples=struct.unpack('<'+'h'*(len(packet.audio)//2),packet.audio)
                rms=math.sqrt(sum(v*v for v in samples)/max(1,len(samples)))
                metrics.append({'time':time.time(),'samples':len(samples),'rms':round(rms,3)})
        except Exception as e:
            metrics.append({'time':time.time(),'ended':type(e).__name__})
        finally:stream.cancel()
    (q/(label+'-'+suffix+'-speaker-metrics.json')).write_text(json.dumps(metrics))

threads=[]
for side,freq in [('a',440),('b',880)]:
    for fn,args in [(inject,(side,freq))]+([(capture,(side,))] if capture_enabled else []):
        thread=threading.Thread(target=fn,args=args,daemon=True);thread.start();threads.append(thread)
print('Synthetic dual-microphone injection started; speaker capture='+str(capture_enabled),flush=True)
stop.wait(duration);stop.set()
for thread in threads:thread.join(4)
(q/(label+'-receipt.json')).write_text(json.dumps({'start':started,'end':time.time(),'sources':receipts},indent=2))
print('Synthetic media streams retained LOCAL_ONLY',flush=True)
if len(receipts)!=2 or any(item['injection']!='completed' for item in receipts):
    raise SystemExit(1)
