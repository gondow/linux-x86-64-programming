# gdb-script.py
class python_test (gdb.Command):
    """Python Script Test"""

    def __init__ (self):
        super (python_test, self).__init__ (
            "python_test", gdb.COMMAND_USER
        )

    def invoke (self, args, from_tty):
        val = gdb.parse_and_eval (args)
        print ("args = " + args)
        print ("val  = " + str (val))
        gdb.execute ("p/x" + str (val) + "\n");

python_test ()        
