import queue as Queue
import subprocess
import threading
import os

import click
import curses


class CustomThread(threading.Thread):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._stop_event = threading.Event()

    def stop_thread(self):
        self._stop_event.set()


class AsynchronousFileReader(CustomThread):
    '''
    Helper class to implement asynchronous reading of a file
    in a separate thread. Pushes read lines on a queue to
    be consumed in another thread.
    '''

    def __init__(self, fd, queue):
        assert isinstance(queue, Queue.Queue)
        assert callable(fd.readline)
        threading.Thread.__init__(self)
        self._fd = fd
        self._queue = queue

    def run(self):
        '''The body of the tread: read lines and put them on the queue.'''
        for line in iter(self._fd.readline, ''):
            if line is not None:
                try:
                    line = line.strip()
                    line = line.decode("utf-8")
                except:
                    pass
            self._queue.put(line)

    def eof(self):
        '''Check whether there is no more content to expect.'''
        return not self.is_alive() and self._queue.empty()


@click.command()
@click.option('--device', default=None, help='Target device')
def start(device=None):
    # You'll need to add any command line arguments here
    cmds = [os.environ["HOME"] + "/Library/Android/sdk/platform-tools/adb"]
    if device is not None:
        cmds += ["-s", device]
    cmds += ["logcat"]
    process = subprocess.Popen(cmds, stdout=subprocess.PIPE)
    # pid = os.getpgid(process.pid)
    # # Launch the asynchronous readers of the process' stdout.
    stdout_queue = Queue.Queue()
    stdout_reader = AsynchronousFileReader(process.stdout, stdout_queue)
    stdout_reader.start()

    # while not stdout_reader.eof():
    #     while not stdout_queue.empty():
    #         line = stdout_queue.get()

    #         print(line)

    def main(stdscr):
        key = ""

        stdscr.clear()
        stdscr.refresh()
        height, width = stdscr.getmaxyx()
        # win.addstr("Detected key:")

        max_width = width - 10

        index = 0

        while not stdout_reader.eof():
            while not stdout_queue.empty():
                line = stdout_queue.get()

                line_size = len(line)

                if line_size > max_width:
                    line = line[:max_width]

                stdscr.clear()
                stdscr.addstr(0, 0, line)

                #   zindex += 1

                # try:
                #     key = stdscr.getkey()
                # except:
                #     pass

                # if key == "q":
                #     os.killpg(pid, signal.SIGTERM)  # Send the signal to all the process groups
                #     stdout_reader.stop_thread()
                #     return

        curses.wrapper(main)


if __name__ == '__main__':
    start()
