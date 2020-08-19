"""
    Main Module responsible for client communication
"""
from scrolls.base.baseclient import ScrollClient
from scrolls.comm.udp import UdpChannel


class DroidClient:
    def __init__(self):
        target_channel = UdpChannel()
        target_channel.host = "127.0.0.1"
        target_channel.port = 9000

        self._client = ScrollClient()
        self.comm_channel = target_channel

    def run(self):
        self._client.command_loop()
