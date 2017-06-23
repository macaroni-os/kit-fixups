----------------
Security Fixes
----------------
=sys-devel/glibc-2.23-r4

https://nvd.nist.gov/vuln/detail/CVE-2017-1000366
glibc contains a vulnerability that allows specially crafted LD_LIBRARY_PATH values to manipulate the heap/stack, causing them to alias, potentially resulting in arbitrary code execution. Please note that additional hardening changes have been made to glibc to prevent manipulation of stack and heap memory but these issues are not directly exploitable, as such they have not been given a CVE. This affects glibc 2.25 and earlier.

https://nvd.nist.gov/vuln/detail/CVE-2016-6323
The makecontext function in the GNU C Library (aka glibc or libc6) before 2.25 creates execution contexts incompatible with the unwinder on ARM EABI (32-bit) platforms, which might allow context-dependent attackers to cause a denial of service (hang), as demonstrated by applications compiled using gccgo, related to backtrace generation.

https://sourceware.org/bugzilla/show_bug.cgi?id=18784
If T_UNSPEC (62321) is passed to functions such as res_query as a record type , libresolv will dereference a NULL pointer, crashing the process.  This is a very minor security vulnerability because it is conceivable that the RR type is supplied by an untrusted party. The expected behavior is that libresolv sends a TYPE62321 query to the configured forwarders because it is a valid record type as far as DNS is concerned.


