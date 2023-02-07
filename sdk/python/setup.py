from setuptools import setup

# def version():
#     with open("VERSION") as version_file:
#         return version_file.read().strip()

def version():
    return "v0.2.0"

setup(
    name="kadalu_volgen",
    version=version(),
    packages=["kadalu_volgen"],
    include_package_data=True,
    install_requires=[],
    platforms="linux",
    zip_safe=False,
    author="Kadalu Authors",
    author_email="maintainers@kadalu.tech",
    description="Kadalu Volfile Generation",
    license="GPL-3.0",
    keywords="kadalu, volgen, volfile",
    url="https://github.com/kadalu/volgen",
    long_description="""
    Kadalu Volgen - CLI to generate Volfiles for
    Kadalu Storage or GlusterFS
    """,
    classifiers=[
        "Topic :: Utilities",
        "Environment :: Console",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3 :: Only",
    ],
)
