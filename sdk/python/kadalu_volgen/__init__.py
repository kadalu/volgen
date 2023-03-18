"""
Kadalu Storage or GlusterFS Volfile generation
"""
import json
import os
import subprocess
import tempfile


class VolfileException(IOError):
    """
    Volfile Exception
    """


def generate(template_file, data=None, data_file=None, options=None,
             options_file=None, output_file=None):
    """
    Generate volfile
    """
    args = ["/usr/bin/kadalu-volgen", "--template", template_file]
    tmp_data_file_name = None
    tmp_options_file_name = None

    if data is not None:
        with tempfile.NamedTemporaryFile(mode="w", delete=False) as tmp_file:
            tmp_file.file.write(json.dumps(data))
            tmp_data_file_name = tmp_file.name

        args += ["--data", tmp_data_file_name]

    if options is not None:
        with tempfile.NamedTemporaryFile(mode="w") as tmp_file:
            for key, value in options.items():
                tmp_file.file.write(f"{key}={value}\n")
            tmp_options_file_name = tmp_file.name

        args += ["--options", tmp_options_file_name]

    if data_file is not None:
        args += ["--data", data_file]

    if options_file is not None:
        args += ["--options", options_file]

    if output_file is not None:
        args += ["--output", output_file]

    with subprocess.Popen(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True
    ) as proc:
        out, err = proc.communicate()

        if tmp_data_file_name is not None and os.path.exists(tmp_data_file_name):
            os.remove(tmp_data_file_name)

        if tmp_options_file_name is not None and os.path.exists(tmp_options_file_name):
            os.remove(tmp_options_file_name)

        if proc.returncode == 0:
            if output_file is not None:
                return

            return out.strip()

    raise VolfileException(proc.returncode, err.strip())
