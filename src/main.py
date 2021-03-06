#!/usr/bin/env python3
from trigger import Trigger

def main():
    client = Trigger(server_url='192.168.5.1:18000')
    streams_xml = client.get_info('STREAMS')
    print(streams_xml)

    client.select_stream(net='AM', station='R8772', selector='EHZ')

    client.run()

if __name__ == "__main__":
    main()