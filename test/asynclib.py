import threading
import subprocess

class Deferrer(threading.Thread):
  def __init__(self, task, onComplete=None):
    threading.Thread.__init__(self)
    self.__task = task
    self.__onComplete = onComplete

  def run(self):
    self.__task()

    if self.__onComplete:
      self.__onComplete()


class AsyncTaskDeferrer():
  def __init__(self, task, callback):
    self.__task = task
    self.__callback = callback

    self.__thread = Deferrer(task.wait, self._taskDoneCallback)
    self.__thread.start()

  def _taskDoneCallback(self):
    if self.__callback:
      self.__callback(self.__task.result)

  def join(self):
    self.__thread.join()


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
