# Builds a zip file from the source_dir or source_file.
# Installs dependencies with pip automatically.
import hash
import os
import shlex
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


@contextmanager
def tempdir():
    """
    Creates a temporary directory and then deletes it afterwards.

    """

    print('mktemp -d')
    path = tempfile.mkdtemp(prefix='terraform-aws-lambda-', dir='/tmp')
    print(path)
    try:
        yield path
    finally:
        shutil.rmtree(path)


def dequote(value):
    """
    Handles quotes around values in a shell-compatible fashion.

    """
    return ' '.join(shlex.split(value))


filename = dequote(sys.argv[1])
runtime = dequote(sys.argv[2])
source_path = dequote(sys.argv[3])

absolute_filename = os.path.abspath(filename)

if os.path.isdir(source_path):
    source_dir = source_path
    source_files = list_files(source_path)
else:
    source_dir = os.path.dirname(source_path)
    source_files = [os.path.basename(source_path)]

cmd = [
    'docker',
    'run',
    '--rm',
    '-t',
    '-v', '%s:/src' % source_dir,
    '-v', '%s:/out' % os.path.abspath(hash.DIRNAME_BUILDS),
    'lambci/lambda:build-%s' % runtime,
    'bash', '-c',
    ''' cp -r /src /build &&
        cd /build &&
        pip3 install --progress-bar off -r requirements.txt --target . &&
        find . -name \\*\\.pyc -exec mv '{}' . \\; &&
        find . -name \\*\\.so -exec strip '{}' \\; &&
        find . -type d -name \\*-info -prune -exec rm -rdf '{}' \\; &&
        find . -type d -name tests -prune -exec rm -rdf '{}' \\; &&
        find . -type d -name boto3 -prune -exec rm -rdf '{}' \\; &&
        find . -type d -name botocore -prune -exec rm -rdf '{}' \\; &&
        find . -type d -name docutils -prune -exec rm -rdf '{}' \\; &&
        find . -type d -name dateutil -prune -exec rm -rdf '{}' \\; &&
        find . -type d -name jmespath -prune -exec rm -rdf '{}' \\; &&
        find . -type d -name s3transfer -prune -exec rm -rdf '{}' \\; &&
        find . -type d -name doc -prune -exec rm -rdf '{}' \\; &&
        chmod -R 755 . &&
        zip -r /out/%s . &&
        chown $(stat -c '%%u:%%g' /out) /out/%s
    ''' % (os.path.basename(filename), os.path.basename(filename))
]
print(cmd)
subprocess.run(cmd)

print('out dir %s' % os.path.abspath(hash.DIRNAME_BUILDS))
print('Created {}'.format(filename))
