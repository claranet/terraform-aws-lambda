#!/usr/bin/env python
#
# Generates a content hash of the source_dir or source_file, which is used to
# determine whether the Lambda code has changed, ignoring file modification
# and access times.
#
# Outputs a filename and a command to run if the archive needs to be built.
#

from __future__ import print_function

import base64
import datetime
import hashlib
import json
import os
import re
import sys


FILENAME_PREFIX = 'tf-aws-lambda-'
FILENAME_PATTERN = re.compile(r'^' + FILENAME_PREFIX + r'[0-9a-f]{64}\.zip$')


def abort(message):
    """
    Exits with an error message.

    """

    sys.stderr.write(message + '\n')
    sys.exit(1)


def delete_old_archives():
    """
    Deletes previously created archives.

    """

    now = datetime.datetime.now()
    delete_older_than = now - datetime.timedelta(hours=6)

    top = '.terraform'
    if os.path.isdir(top):
        for name in os.listdir(top):
            if FILENAME_PATTERN.match(name):
                path = os.path.join(top, name)
                file_modified = datetime.datetime.fromtimestamp(
                    os.path.getmtime(path)
                )
                if file_modified < delete_older_than:
                    os.remove(path)


def list_files(top_path):
    """
    Returns a sorted list of all files in a directory.

    """

    results = []

    for root, dirs, files in os.walk(top_path):
        for file_name in files:
            results.append(os.path.join(root, file_name))

    results.sort()
    return results


def generate_content_hash(source_dir, source_file):
    """
    Generate a content hash of the source_dir or source_file.

    """

    sha256 = hashlib.sha256()

    if source_dir:
        for source_file in list_files(source_dir):
            update_hash(sha256, source_dir, source_file)

    elif source_file:
        source_dir = os.path.dirname(source_file)
        update_hash(sha256, source_dir, source_file)

    return sha256


def update_hash(hash_obj, file_root, file_path):
    """
    Update a hashlib object with the relative path and contents of a file.

    """

    relative_path = os.path.relpath(file_path, file_root)
    hash_obj.update(relative_path)

    with open(file_path, 'rb') as open_file:
        while True:
            data = open_file.read(1024)
            if not data:
                break
            hash_obj.update(data)


current_dir = os.path.dirname(__file__)

# Parse the query.
if len(sys.argv) > 1 and sys.argv[1] == '--test':
    query = {
        'runtime': 'python3.6',
        'source_dir': os.path.join(current_dir, 'tests', 'pip3', 'lambda'),
        'source_file': '',
    }
else:
    query = json.load(sys.stdin)
runtime = query['runtime']
source_dir = query['source_dir']
source_file = query['source_file']

# Validate the query.
if source_dir and source_file:
    abort('source_dir and source_file cannot both be set.')
if not source_dir and not source_file:
    abort('source_dir or source_file must be set.')

# Generate a hash based on file names and content. Also use the
# runtime value and content of build.py because they can have an
# effect on the resulting archive.
content_hash = generate_content_hash(source_dir, source_file)
content_hash.update(runtime)
with open(os.path.join(current_dir, 'build.py')) as build_script_file:
    content_hash.update(build_script_file.read())

# Generate a unique filename based on the hash.
filename = '.terraform/{prefix}{content_hash}.zip'.format(
    prefix=FILENAME_PREFIX,
    content_hash=content_hash.hexdigest(),
)

# Determine the command to run if Terraform wants to build a new archive.
build_command = "python '{build_script}' '{build_data}'".format(
    build_script=os.path.join(current_dir, 'build.py'),
    build_data=base64.b64encode(json.dumps({
        'filename': filename,
        'source_dir': source_dir,
        'source_file': source_file,
        'runtime': runtime,
    })),
)

# Delete previous archives.
delete_old_archives()

# Output the result to Terraform.
json.dump({
    'filename': filename,
    'build_command': build_command,
}, sys.stdout, indent=2)
sys.stdout.write('\n')
