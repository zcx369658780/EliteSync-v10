import sys
import owned
sys.path.insert(0,str(owned.R/'source/tools/v1015/linux_backend/running_engine'))
from supply import Meter
from broker import serve
generation=sys.argv[1] if len(sys.argv)>1 else '1'
owned.need(generation.isdigit() and 1<=int(generation)<=9,'PUMP_GENERATION')
owned.event('SUPPLY_METADATA_PUMP_START',external_listener=False,generation=generation)
print('TASK_METADATA_PUMP_READY',flush=True)
try:serve(owned,Meter(owned,owned.R/'supply/raw'),owned.R/'queue',owned.R/('broker.stop' if generation=='1' else 'broker-stop-'+generation+'.marker'))
except Exception as e:
 owned.event('SUPPLY_METADATA_PUMP_FAILED',error_type=type(e).__name__,error=str(e));print(type(e).__name__,str(e),flush=True);raise
owned.event('SUPPLY_METADATA_PUMP_STOP')
