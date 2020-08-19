"""
    Main Module responsible for server loop
"""
from scrolls.base.baseserver import ScrollServer
from scrolls.comm.udp import UdpChannel


class DroidServer:
    def __init__(self):
        target_channel = UdpChannel()
        target_channel.host = "127.0.0.1"
        target_channel.port = 9000

        self._server = ScrollServer()
        self._server.comm_channel = target_channel
        self._server._process_command = self.receive_client_command

    def receive_client_command(self, command):
        print(command)

    def run(self):
        self._server.run()
