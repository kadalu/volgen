# Kadalu Storage Volfile generation

Template based Volfile generation.

## Install

Run below command to download and install the `kadalu-volgen` tool.

```
curl -fsSL https://github.com/kadalu/volgen/releases/latest/download/install.sh | sudo bash -x
```

## Usage - CLI

Print the generated volfile to `STDOUT`

```
kadalu-volgen -t client.vol.j2 -d volinfo.json
```

Output to a file

```
kadalu-volgen -t client.vol.j2 -d volinfo.json -o /var/lib/kadalu/volfiles/vol1.vol
```

With Options file

```
kadalu-volgen -t client.vol.j2 -d volinfo.json -c volopts.dat -o /var/lib/kadalu/volfiles/vol1.vol
```

## Usage - Python SDK

```python
import kadalu_volgen

content = kadalu_volgen.generate(
    "client.vol.j2",
    data={"name": "vol1", ..},
)

# Output to a file
kadalu_volgen.generate(
    "client.vol.j2",
    data={"name": "vol1", ..},
    output_file="/var/lib/kadalu/volfiles/vol1.vol"
)

# Specify Options
kadalu_volgen.generate(
    "client.vol.j2",
    data={"name": "vol1", ..},
    options={"diagnostics.client-log-level": "DEBUG"},
    output_file="/var/lib/kadalu/volfiles/vol1.vol"
)
```

## Example data files

### Client

```
{
    "name": "vol1",
    "id": "1bf444e1-25c8-479f-91fa-b83fd326f576",
    "distribute_groups": [
        {
            "type": "replicate",
            "replica_count": 2,
            "storage_units": [
                {
                    "path": "/exports/vol1/s1",
                    "port": 49252,
                    "node": {
                        "name": "server1",
                        "id": "2d2ea3aa-6c0e-4bcc-8072-8eab999a4148"
                    }
                },
                {
                    "path": "/exports/vol1/s2",
                    "port": 49252,
                    "node": {
                        "name": "server2",
                        "id": "6c0d3eea-7033-45fd-b614-2f30efbb5fae"
                    }
                }
            ]
        },
        {
            "type": "replicate",
            "replica_count": 2,
            "storage_units": [
                {
                    "path": "/exports/vol1/s3",
                    "port": 49252,
                    "node": {
                        "name": "server3",
                        "id": "b19135eb-53b8-4800-af34-fb1f7d2112af"
                    }
                },
                {
                    "path": "/exports/vol1/s4",
                    "port": 49252,
                    "node": {
                        "name": "server4",
                        "id": "abc58134-70af-4795-838f-837b19d9018e"
                    }
                }
            ]
        }
    ]
}
```

### Storage Unit

```json
{
    "path": "/exports/vol1/s1",
    "port": 49252,
    "node": {
        "name": "server1",
        "id": "2d2ea3aa-6c0e-4bcc-8072-8eab999a4148"
    },
    "volume": {
        "id": "1bf444e1-25c8-479f-91fa-b83fd326f576",
        "name": "vol1"
    }
}
```

### Options

```
diagnostics.client-log-level=DEBUG
performance.write-behind=off
```

