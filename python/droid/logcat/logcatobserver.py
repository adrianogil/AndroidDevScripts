""" Class responsible for monitoring ADB logcat """
from droid.utils.decorators import handle_errors

import threading
import subprocess
import signal
import queue
import time
import os


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
    def __init__(self, fd, _queue):
        super().__init__()
        assert isinstance(_queue, queue.Queue)
        assert callable(fd.readline)
        self._fd = fd
        self._queue = _queue
        self.is_running = False

    def run(self):
        '''The body of the tread: read lines and put them on the queue.'''
        for line in iter(self._fd.readline, ''):
        # for line in io.TextIOWrapper(self._fd, encoding="utf-8"):
            # print(("AsynchronousFileReader::run - got line:\n" + line)
            if line is not None:
                line = line.strip()
            if self.is_running:
                self._queue.put(line)
            else:
                return

    def eof(self):
        '''Check whether there is no more content to expect.'''
        return not self.is_alive() and self._queue.empty() and self.is_running


class AndroidLogcatObserver:
    def __init__(self):
        self.logcat_process = None
        self.process = None
        self.observer_list = []
        self.is_running = False
        self.loop_thread = None

    @handle_errors(
        error_message="Error while stopping logcat observer",
        stacktrace=True
    )
    def stop(self):
        self.is_running = False
        self.logcat_process.is_running = False
        self.process.kill()
        self.process.terminate()
        os.kill(self.process.pid, signal.SIGKILL)
        self.logcat_process.stop()
        self.loop_thread.stop()
        self.logcat_process.join()
        self.loop_thread.join()

    def setup(self, device=None):
        mtag = "LogcatObserver:setup"
        if self.is_running:
            print(mtag + " - logcat observer already running")
            return

        # You'll need to add any command line arguments here.
        cmds = [os.environ["HOME"] + "/Library/Android/sdk/platform-tools/adb"]
        if device is not None:
            cmds += ["-s", device]
        cmds += ["logcat"]
        print(mtag + " - running cmd: %s" % (cmds,))

        self.process = subprocess.Popen(cmds,
                                        stdout=subprocess.PIPE,
                                        encoding="utf-8",
                                        universal_newlines=True)

        # Launch the asynchronous readers of the process' stdout.
        stdout_queue = queue.Queue()
        self.logcat_process = AsynchronousFileReader(self.process.stdout, stdout_queue)
        self.logcat_process.start()
        self.loop_thread = self.run_logcat(error_callback=self.handle_logcat_error)

    def add_observer(self, observer):
        if observer not in self.observer_list:
            self.observer_list.append(observer)

    @handle_errors(
        error_message="Error while running logcat observer",
        stacktrace=True
    )
    def run_logcat(self):
        mtag = "LogcatObserver:run_logcat - "
        print(mtag)

        self.is_running = True
        self.logcat_process.is_running = True
        # Check the queues if we received some output
        # (until there is nothing more to get).
        while self.is_running and not self.logcat_process.eof():
            try:
                line = self.logcat_process._queue.get(block=True, timeout=3)
                for observer in self.observer_list:
                    try:
                        observer(line)
                    except Exception as e:
                        print(mtag + " error running observer %s: %s" % (observer, e,))
            except Exception as exception:
                print("logcat exception: %s" % (exception,))
    
    def handle_logcat_error(self):
        print("Logcat error!")


class LogFilter:
    def __init__(self):
        self.logcat_observer = AndroidLogcatObserver()
        self.logcat_observer.add_observer(self.filter_log)
        self.filter_string = ""

    def filter_log(self, log_line):
        if self.filter_string.lower() in log_line.lower():
            print(log_line)

    def run(self):
        self.logcat_observer.setup()


if __name__ == '__main__':
    import sys

    log_filter = LogFilter()
    log_filter.filter_string = sys.argv[1]
    log_filter.run()

    while True:
        time.sleep(500)
