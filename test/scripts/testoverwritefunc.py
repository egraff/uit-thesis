class Blah():
  def __init__(self):
    print "INIT"

  def doSomething(self):
    print "do something"

  def doSomethingElse(self):
    print "do something else"

  def replace(self):
    self.doSomething = self.doSomethingElse


a = Blah()
a.doSomething()
a.replace()
a.doSomething()
