# Builds a zip file from the source_dir or source_file.
# Installs dependencies with pip automatically.

import os
import shutil
import subprocess
import sys
import tempfile

from contextlib import contextmanager


@contextmanager
def cd(path):
    """
    Changes the working directory.

    """

    cwd = os.getcwd()
    print('cd', path)
    try:
        os.chdir(path)
        yield
    finally:
        os.chdir(cwd)


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
    path = tempfile.mkdtemp(prefix='terraform-aws-lambda-')
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
    target_base, _ = os.path.splitext(target_file)
    shutil.make_archive(
        target_base,
        format='zip',
        root_dir=source_dir,
    )


filename = sys.argv[1]
runtime = sys.argv[2]
source_path = sys.argv[3]

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
    with cd(source_dir):
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
            with cd(temp_dir):
                if runtime.startswith('python3'):
                    pip_command = 'pip3'
                else:
                    pip_command = 'pip2'
                run(
                    pip_command,
                    'install',
                    '--prefix=',
                    '--target=.',
                    '--requirement=requirements.txt',
                )

    # Zip up the temporary directory and write it to the target filename.
    # This will be used by the Lambda function as the source code package.
    create_zip_file(temp_dir, absolute_filename)
    print('Created {}'.format(filename))
