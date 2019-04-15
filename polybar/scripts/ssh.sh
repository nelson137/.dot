#!/bin/bash

# Prevent a core dump if ss segfaults
ulimit -c 0

count_out() { grep -c 'ssh$'; }
count_in()  { grep -c '^ssh'; }

get_sessions_counts() {
    local only_ssh_ports='( dport = :ssh or sport = :ssh )'
    local ip='[0-9\.]+'
    local port='[0-9]+|ssh'

    ss -H state established "$only_ssh_ports" \
      | sed -E "s/.+ $ip:($port)\s+$ip:($port).*/\\1 \\2/" \
      | tee >(count_out) >(count_in) >/dev/null
}

counts="$({ get_sessions_counts; } 2>/dev/null)"
counts="${counts:-0 0}"
outbound="$(tail -1 <<< "$counts")"
inbound="$(head -1 <<< "$counts")"
echo "$outbound $inbound"
