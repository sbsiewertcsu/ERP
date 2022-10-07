#!/usr/bin/env python3
from trigger import Trigger
from multiprocessing import Process

def trigger(sta, lta, thresh_on, thresh_off):
    client = Trigger(server_url='192.168.5.1:18000', sta=sta, lta=lta,
                     trig_on=thresh_on, trig_off=thresh_off)
    streams_xml = client.get_info('STREAMS')
    print(streams_xml)

    client.select_stream(net='AM', station='R8772', selector='EHZ')

    client.run()


def main():
    p_0 = Process(target=trigger, args=(2, 8, 2.5, 1.0))
    p_1 = Process(target=trigger, args=(2, 10, 2.0, 1.0))
    p_2 = Process(target=trigger, args=(1.5, 5, 1.5, 0.5))

    p_0.start()
    p_1.start()
    p_2.start()

    p_0.join()
    p_1.join()
    p_2.join()




if __name__ == "__main__":
    main()