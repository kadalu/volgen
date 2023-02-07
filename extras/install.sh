#!/bin/bash

curl -fsSL https://github.com/kadalu/volgen/releases/latest/download/kadalu-volgen-`uname -m | sed 's|aarch64|arm64|' | sed 's|x86_64|amd64|'` -o /tmp/kadalu-volgen
curl -fsSL https://github.com/kadalu/volgen/releases/latest/download/disperse.vol.j2 -o /tmp/disperse.vol.j2
curl -fsSL https://github.com/kadalu/volgen/releases/latest/download/replica2.vol.j2 -o /tmp/replica2.vol.j2
curl -fsSL https://github.com/kadalu/volgen/releases/latest/download/replica3.vol.j2 -o /tmp/replica3.vol.j2
curl -fsSL https://github.com/kadalu/volgen/releases/latest/download/storage_unit.vol.j2 -o /tmp/storage_unit.vol.j2
curl -fsSL https://github.com/kadalu/volgen/releases/latest/download/__init__.py -o /tmp/__init__.py
curl -fsSL https://github.com/kadalu/volgen/releases/latest/download/setup.py -o /tmp/setup.py

install -m 700 /tmp/disperse.vol.j2 /var/lib/kadalu/templates/
install -m 700 /tmp/replica2.vol.j2 /var/lib/kadalu/templates/
install -m 700 /tmp/replica3.vol.j2 /var/lib/kadalu/templates/
install -m 700 /tmp/storage_unit.vol.j2 /var/lib/kadalu/templates/
install /tmp/kadalu-volgen /usr/bin/kadalu-volgen
mkdir -p /tmp/python/kadalu_volgen
mv /tmp/__init__.py /tmp/python/kadalu_volgen/
mv /tmp/setup.py /tmp/python/
cd /tmp/python/ && python3 setup.py install
