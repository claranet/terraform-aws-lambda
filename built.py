# Builds missing zip files included in the
# Terraform state but missing from the disk.

import json
import os
import subprocess
import sys


# Parse the query.
query = json.load(sys.stdin)
build_command = query['build_command']
filename_old = query['filename_old']
filename_new = query['filename_new']
module_relpath = query['module_relpath']

# If the old filename (from the Terraform state) matches the new filename
# (from hash.py) then the source code has not changed and thus the zip file
# should not have changed.
if filename_old == filename_new:
    if os.path.exists(filename_new):
        # Update the file time so it doesn't get cleaned up,
        # which would result in an unnecessary rebuild.
        os.utime(filename_new, None)
    else:
        # If the file is missing, then it was probably generated on another
        # machine, or it was created a long time ago and cleaned up. This is
        # expected behaviour. However if Terraform needs to upload the file
        # (e.g. someone manually deleted the Lambda function via the AWS
        # console) then it is possible that Terraform will try to upload
        # the missing file. I don't know how to tell if Terraform is going
        # to try to upload the file or not, so always ensure the file exists.
        subprocess.check_output(build_command, shell=True, cwd=module_relpath)

# Output the filename to Terraform.
json.dump({
    'filename': module_relpath + '/' + filename_new,
}, sys.stdout, indent=2)
sys.stdout.write('\n')
