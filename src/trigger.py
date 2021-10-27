#!/usr/bin/env python3
from obspy.clients.seedlink.easyseedlink import EasySeedLinkClient
from obspy.core.trace import Trace
from obspy.signal.trigger import recursive_sta_lta, trigger_onset
from collections import deque
import numpy as np


class Trigger(EasySeedLinkClient):
    def __init__(self, server_url='127.0.0.1:18000', filter_freq=5, sta=2., lta=8.,
                 trig_on=2.5, trig_off=1.0):
        super().__init__(server_url)
        self.buffer = deque(maxlen=15)
        self.on_off = []
        self.net_trace = Trace()
        self.itertrace = None
        self.filter_freq = filter_freq
        self.sta = sta
        self.lta = lta
        self.thresh1 = trig_on
        self.thresh2 = trig_off

    def run_trigger(self):
        self.adjust_buffer()
        try:
            self.net_trace.filter("highpass", freq=self.filter_freq)
            df = self.net_trace.stats.sampling_rate
            cft = recursive_sta_lta(self.net_trace.data, int(self.sta * df), int(self.lta * df))
            self.on_off = trigger_onset(cft, self.thresh1, self.thresh2)
            print("Trigger_Onset: ", str(self.on_off), len(self.on_off))
            if len(self.on_off) > 0:
                print("Event Detected")
                self.flush_buffers()
            else:
                pass
        except Exception as e:
            print("Error:", e)

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

    def adjust_buffer(self):
        self.net_trace = self.buffer[0]
        self.itertrace = iter(self.buffer)
        next(self.itertrace)
        for i in self.itertrace:
            self.net_trace += i

    def flush_buffers(self):
        self.buffer.clear()
        self.on_off = np.empty(self.on_off.shape)
        self.net_trace = Trace()




