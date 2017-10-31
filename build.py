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
            file_path = os.path.join(root, file_name)
            relative_path = os.path.relpath(file_path, top_path)
            results.append(relative_path)

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

    print('mktemp -d')
    path = tempfile.mkdtemp(prefix='tf-aws-lambda-')
    print(path)
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
source_path = query['source_path']

absolute_filename = os.path.abspath(filename)

# Create a temporary directory for building the archive,
# so no changes will be made to the source directory.
with tempdir() as temp_dir:

    # Find all source files.
    if os.path.isdir(source_path):
        source_dir = source_path
        source_files = list_files(source_path)
    else:
        source_dir = os.path.dirname(source_path)
        source_files = [os.path.basename(source_path)]

    # Copy them into the temporary directory.
    cd(source_dir)
    for file_name in source_files:
        target_path = os.path.join(temp_dir, file_name)
        target_dir = os.path.dirname(target_path)
        if not os.path.exists(target_dir):
            print('mkdir -p {}'.format(target_dir))
            os.makedirs(target_dir)
        print('cp {} {}'.format(file_name, target_path))
        shutil.copyfile(file_name, target_path)

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
