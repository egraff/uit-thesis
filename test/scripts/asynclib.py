import threading
import subprocess
import Queue
import sys

class Deferrer(threading.Thread):
  def __init__(self, taskFunc, onComplete=None, exceptionQueue=None):
    threading.Thread.__init__(self)
    self.__taskFunc = taskFunc
    self.__onComplete = onComplete
    self.__exceptionQueue = exceptionQueue

  def run(self):
    try:
      self.__taskFunc()
    except Exception:
      if self.__exceptionQueue:
        self.__exceptionQueue.put(sys.exc_info())
    else:
      try:
        if self.__onComplete:
          self.__onComplete()
      except Exception:
        if self.__exceptionQueue:
          self.__exceptionQueue.put(sys.exc_info())


class AsyncTaskDeferrer():
  def __init__(self, task, callback):
    self.__task = task
    self.__callback = callback
    self.__exceptionQueue = Queue.Queue()

    self.__thread = Deferrer(task.wait, self._taskDoneCallback, self.__exceptionQueue)
    self.__thread.start()

  def _taskDoneCallback(self):
    if self.__callback:
      self.__callback(self.__task.result)

  def join(self):
    self.__thread.join()

    # See if joined thread generated exception
    try:
      exc = self.__exceptionQueue.get(block=False)
    except Queue.Empty:
      pass # No exceptions
    else:
      exc_type, exc_obj, exc_trace = exc

      # Re-raise same exception from faulting thread
      raise exc_type, exc_obj, exc_trace


class AsyncTask(object):
  def wait(self):
    raise NotImplementedError()

  @property
  def result(self):
    raise NotImplementedError()

  def await(self, callback=None):
    deferrer = AsyncTaskDeferrer(self, callback)
    self.wait = deferrer.join


class JoinedAsyncTask(AsyncTask):
  def __init__(self, *tasks):
    self.__tasks = tasks

  def wait(self):
    for task in self.__tasks:
      task.wait()

  @property
  def result(self):
    return (task.result for task in self.__tasks)


class AsyncPopen(AsyncTask):
  def __init__(self, *args, **kwargs):
    self.__proc = subprocess.Popen(*args, **kwargs)

  def wait(self):
    self.__proc.wait()

  @property
  def result(self):
    return self.__proc
