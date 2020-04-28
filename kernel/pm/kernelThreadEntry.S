.text
.globl kernelThreadEntry
kernelThreadEntry:          # void kernelThread()

    pushl %edx              # push arg
    call *%ebx              # call fn

    pushl %eax              # save the return value of fn(arg)
    call _ZN2PM6doExitEi    # call doExit to terminate current thread