----------------
Security Fixes
----------------
=app-admin/sudo-1.8.20_beta1-r1

https://nvd.nist.gov/vuln/detail/CVE-2017-1000367
Todd Miller's sudo version 1.8.20 and earlier is vulnerable to an input validation (embedded spaces) in the get_process_ttyname() function resulting in information disclosure and command execution.

=mail-mta/exim-4.89-r1

https://nvd.nist.gov/vuln/detail/CVE-2017-1000369
Exim supports the use of multiple "-p" command line arguments which are malloc()'ed and never free()'ed, used in conjunction with other issues allows attackers to cause arbitrary code execution. This affects exim version 4.89 and earlier. Please note that at this time upstream has released a patch (commit 65e061b76867a9ea7aeeb535341b790b90ae6c21), but it is not known if a new point release is available that addresses this issue at this time.


