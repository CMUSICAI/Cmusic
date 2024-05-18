# CmusicAI Seed Generation

Utility to generate the `seeds.txt` list that is compiled into the client (see [src/chainparamsseeds.h](/src/chainparamsseeds.h) and other utilities in [contrib/seeds](/contrib/seeds)).

Be sure to update `PATTERN_AGENT` in `makeseeds.py` to include the current version, and remove old versions as necessary.

## Steps to Generate Seeds

1. **Fetch the Peer Data:**

   Use `curl` to get the peer data from the provided URL:

   ```shell
   curl -s https://explorer.cmusic.ai/ext/getnetworkpeers > peers.json
   ```

2. **Run `makeseeds.py`:**

   With `seeds_main.txt` generated, run `makeseeds.py`:

   ```shell
   python3 makeseeds.py > nodes_main.txt
   ```

3. **Generate `chainparamsseeds.h`:**

   Run `generate-seeds.py` to create `chainparamsseeds.h`:

   ```shell
   python3 generate-seeds.py . > ../../src/chainparamsseeds.h
   ```

## Dependencies

Ensure you have the necessary dependencies installed. For Ubuntu, install `python3-dnspython`:

```shell
sudo apt-get install python3-dnspython
```

For macOS, install `dnspython`:

```shell
pip3 install --user dnspython
```

By following these steps, you will generate the necessary seed data to be compiled into the CmusicAI client, aiding new clients in connecting to the network.
