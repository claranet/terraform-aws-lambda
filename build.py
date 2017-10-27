#!/usr/bin/env python
#
# Builds a zip file from the source_dir or source_file.
# Installs dependencies with pip automatically.
#

from __future__ import print_function

import base64
import json
import os
import shutil
import subprocess
import sys
import tempfile

from contextlib import contextmanager


def cd(path):
    """
    Changes the working directory.

    """

    if os.getcwd() != path:
        print('cd', path)
        os.chdir(path)


def format_command(command):
    """
    Formats a command for displaying on screen.

    """

    args = []
    for arg in command:
        if ' ' in arg:
            args.append('"' + arg + '"')
        else:
            args.append(arg)
    return ' '.join(args)


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


def run(*args, **kwargs):
    """
    Runs a command.

    """

    print(format(format_command(args)))
    sys.stdout.flush()
    subprocess.check_call(args, **kwargs)


@contextmanager
def tempdir():
    """
    Creates a temporary directory and then deletes it afterwards.

    """

    path = tempfile.mkdtemp(prefix='tf-aws-lambda-')
    try:
        yield path
    finally:
        shutil.rmtree(path)


def create_zip_file(source_dir, target_file):
    """
    Creates a zip file from a directory.

    """

    target_file = os.path.abspath(target_file)
    target_dir = os.path.dirname(target_file)
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)
    cd(source_dir)
    run('zip', '-r', target_file, '.')


# Parse the data from hash.py
query = json.loads(base64.b64decode(sys.argv[1]))
filename = query['filename']
runtime = query['runtime']
source_dir = query['source_dir']
source_file = query['source_file']

absolute_filename = os.path.abspath(filename)

# Create a temporary directory for building the archive,
# so no changes will be made to the source directory.
with tempdir() as temp_dir:

    # Find all source files.
    if source_file:
        source_dir = os.path.dirname(source_file)
        source_files = [os.path.basename(source_file)]
    elif source_dir:
        source_files = list_files(source_dir)

    # Copy them into the temporary directory.
    for source_path in source_files:
        relative_path = os.path.relpath(source_path, source_dir)
        target_path = os.path.join(temp_dir, relative_path)
        target_dir = os.path.dirname(target_path)
        if not os.path.exists(target_dir):
            os.makedirs(target_dir)
        shutil.copyfile(source_path, target_path)

    # Install dependencies into the temporary directory.
    if runtime.startswith('python'):
        requirements = os.path.join(temp_dir, 'requirements.txt')
        if os.path.exists(requirements):
            cd(temp_dir)
            run('pip', 'install', '-r', 'requirements.txt', '-t', '.')

    # Zip up the temporary directory and write it to the target filename.
    # This will be used by the Lambda function as the source code package.
    create_zip_file(temp_dir, absolute_filename)
    print('Created {}'.format(filename))
