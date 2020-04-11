import queue as Queue
import subprocess
import threading
import os


class AsynchronousFileReader(threading.Thread):
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
                line = line.decode("utf-8")
            self._queue.put(line)

    def eof(self):
        '''Check whether there is no more content to expect.'''
        return not self.is_alive() and self._queue.empty()


# You'll need to add any command line arguments here.
process = subprocess.Popen([os.environ["HOME"] + "/Library/Android/sdk/platform-tools/adb", "logcat"], stdout=subprocess.PIPE)

# Launch the asynchronous readers of the process' stdout.
stdout_queue = Queue.Queue()
stdout_reader = AsynchronousFileReader(process.stdout, stdout_queue)
stdout_reader.start()


while not stdout_reader.eof():
    while not stdout_queue.empty():
        line = stdout_queue.get()

        print(line)
