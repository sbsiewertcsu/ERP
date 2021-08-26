#!/usr/bin/env python3
import obspy
from obspy.clients.seedlink.easyseedlink import create_client, EasySeedLinkClient
from obspy.core import read
from obspy.core.stream import Stream
from obspy.signal.trigger import plot_trigger, classic_sta_lta, trigger_onset
from collections import deque
from obspy import Trace, read
from termcolor import colored

class seedlink(EasySeedLinkClient):
    def __init__(self,server_url):
        super().__init__(server_url)
        self.buffer = deque(maxlen=15)
        self.on_off = []
    def run_trigger(self,trace):
        if (len(self.buffer) < 10):
            pass
        else:
            net_trace = self.buffer[0]
            itertrace = iter(self.buffer)
            next(itertrace)
            for i in itertrace:
                net_trace += i
                print(net_trace.data)
                print(len(net_trace.data))
                try:
                    df = net_trace.stats.sampling_rate
                    cft = classic_sta_lta(net_trace.data, int(2. * df), int(8. * df))
                    # only computes trigger onset???
                    # perhaps from onset create another ring buffer and add data to that ring buffer
                    self.on_off = trigger_onset(cft, 2.5, 1.0)
                    print("CFT: " + str(cft))
                    print("Trigger_Onset: " ,colored( str(self.on_off),'green'))
                    if len(self.on_off) > 0:
                        #self.on_off[:] = []
                        net_trace2 = net_trace.copy()
                        net_trace2.filter("highpass", freq=10)
                        plot_trigger(net_trace2, cft, 1.5, 0.5)
                        self.on_off[:] = []
                        print("trigger after ------>", str(self.on_off))
                        #continue
                    else:
                        # plot_trigger(net_trace,cft,1.5,0.5)
                        pass
                    # print(str(self.buffer[0].data))
                # plot_trigger(net_trace,cft,1.5,0.5)
                except:
                    print("Error")

    def on_data(self,trace):
        self.buffer.append(trace)
        self.run_trigger(trace)

client = seedlink('192.168.1.15:18000')
streams_xml = client.get_info('STREAMS')
print (streams_xml)

client.select_stream(net='12',station='5BY4',selector='HHZ')
#client.select_stream('HHE','HHN','HHZ')

client.run()