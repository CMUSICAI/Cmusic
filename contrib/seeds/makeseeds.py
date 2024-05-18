#!/usr/bin/env python3
# Copyright (c) 2013-2017 The Bitcoin Core developers
# Copyright (c) 2017-2019 The Raven Core developers
# Copyright (c) 2024 Cmusic.AI
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.
#
# Generate seeds.txt from CmusicAI's JSON peer data
#

import json
import re
import sys
import dns.resolver
import collections

NSEEDS = 512
MAX_SEEDS_PER_ASN = 2
DEFAULT_PORT = 9328  # Set the default port here

# These are hosts that have been observed to be behaving strangely (e.g. aggressively connecting to every node).
SUSPICIOUS_HOSTS = {}

PATTERN_AGENT = re.compile(r"^CmusicAI:1\.0\.1$")  # Pattern to match CmusicAI:1.0.1

def strip_parentheses(version):
    """Remove text within parentheses."""
    return re.sub(r'\(.*?\)', '', version).strip()

def parseline(peer):
    ip = peer['address']
    port = DEFAULT_PORT  # Use the default port
    agent = strip_parentheses(peer['version'])
    protocol = int(peer['protocol'])
    net = 'ipv4'
    sortkey = ip

    return {
        'net': net,
        'ip': ip,
        'port': port,
        'ipnum': ip,
        'version': protocol,
        'agent': agent,
        'sortkey': sortkey,
    }

def filtermultiport(ips):
    '''Filter out hosts with more nodes per IP'''
    hist = collections.defaultdict(list)
    for ip in ips:
        hist[ip['sortkey']].append(ip)
    return [value[0] for (key, value) in list(hist.items()) if len(value) == 1]

# Based on Greg Maxwell's seed_filter.py
def filterbyasn(ips, max_per_asn, max_total):
    # Sift out ips by type
    ips_ipv4 = [ip for ip in ips if ip['net'] == 'ipv4']
    ips_ipv6 = [ip for ip in ips if ip['net'] == 'ipv6']
    ips_onion = [ip for ip in ips if ip['net'] == 'onion']

    # Filter IPv4 by ASN
    result = []
    asn_count = {}
    for ip in ips_ipv4:
        if len(result) == max_total:
            break
        try:
            asn = int([x.to_text() for x in dns.resolver.resolve('.'.join(reversed(ip['ip'].split('.'))) + '.origin.asn.cymru.com', 'TXT').response.answer][0].split('\"')[1].split(' ')[0])
            if asn not in asn_count:
                asn_count[asn] = 0
            if asn_count[asn] == max_per_asn:
                continue
            asn_count[asn] += 1
            result.append(ip)
        except:
            sys.stderr.write('ERR: Could not resolve ASN for "' + ip['ip'] + '"\n')

    # TODO: filter IPv6 by ASN

    # Add back non-IPv4
    result.extend(ips_ipv6)
    result.extend(ips_onion)
    return result

def main():
    with open('peers.json') as f:
        peers = json.load(f)
    ips = [parseline(peer) for peer in peers]

    # Skip entries with invalid addresses.
    ips = [ip for ip in ips if ip is not None]
    # Skip entries from suspicious hosts.
    ips = [ip for ip in ips if ip['ip'] not in SUSPICIOUS_HOSTS]
    # Require a known and recent user agent.
    ips = [ip for ip in ips if PATTERN_AGENT.match(ip['agent'])]
    # Filter out hosts with multiple cmusicai ports, these are likely abusive
    ips = filtermultiport(ips)
    # Look up ASNs and limit results, both per ASN and globally.
    ips = filterbyasn(ips, MAX_SEEDS_PER_ASN, NSEEDS)
    # Sort the results by IP address (for deterministic output).
    ips.sort(key=lambda x: (x['net'], x['sortkey']))

    with open('nodes_main.txt', 'w') as f:
        for ip in ips:
            f.write(f'{ip["ip"]}:{ip["port"]}\n')

if __name__ == '__main__':
    main()
