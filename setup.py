from setuptools import setup

try:
    with open('README.md') as fh:
        LONG_DESC = fh.read()
except (IOError, OSError):
    LONG_DESC = ''

setup(
    name="xontrib-repa-prompt",
    version='0.0.5',
    url='https://github.com/dyuri/xontrib-repa-prompt',
    license='MIT',
    author='Gyuri Horák',
    author_email='dyuri@horak.hu',
    description='Custom prompt for xonsh',
    long_description=LONG_DESC,
    long_description_content_type='text/markdown',
    packages=['xontrib'],
    package_dir={'xontrib': 'xontrib'},
    package_data={'xontrib': ['*.xsh']},
    platforms='any',
    data_files=[("", ["LICENSE.txt"])],
    classifiers=[
        'Environment :: Console',
        'Intended Audience :: End Users/Desktop',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Desktop Environment',
        'Topic :: System :: Shells',
        'Topic :: System :: System Shells',
    ]
)
