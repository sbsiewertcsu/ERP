#!/usr/bin/env python3
from obspy.clients.seedlink.easyseedlink import EasySeedLinkClient
from obspy.signal.trigger import plot_trigger, recursive_sta_lta, trigger_onset
from collections import deque


class Trigger(EasySeedLinkClient):
    def __init__(self, server_url):
        super().__init__(server_url)
        self.buffer = deque(maxlen=15)
        self.on_off = []

    def run_trigger(self):
        net_trace = self.buffer[0]
        itertrace = iter(self.buffer)
        next(itertrace)
        for i in itertrace:
            net_trace += i
            try:
                net_trace.filter("highpass", freq=10)
                df = net_trace.stats.sampling_rate
                cft = recursive_sta_lta(net_trace.data, int(2. * df), int(8. * df))
                self.on_off = trigger_onset(cft, 2.5, 1.0)
                print("CFT: " + str(cft))
                print("Trigger_Onset: ", str(self.on_off))
                if len(self.on_off) > 0:
                    self.on_off[:] = []
                    print("trigger after ------>", str(self.on_off))
                else:
                    pass
            except:
                print("Error")

    def on_data(self, trace):
        self.get_data(trace)
        if self.has_data():
            self.run_trigger()
        else:
            pass

    def get_data(self, trace):
        self.buffer.append(trace)

    def has_data(self):
        return len(self.buffer) > 10

