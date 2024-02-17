# Shell

Beside from some exports, there are some aliases and functions.

If you see in the logs that the task `Deploy .profile for <shell> to user's home` is changed, you need to restart the system to apply the changes.

## Aliases

### General

Print the IPv4 address

```sh
ipv4 
```

Print the IPv6 address

```sh
ipv6
```

Print even numbers from given range (inclusive). Default format is space separated. You can change it to newline or comma separated by passing `newline` or `comma` as the first argument.

```sh
evens <start> <end> [format]
```

Print odd numbers from given range (inclusive). Default format is space separated. You can change it to newline or comma separated by passing `newline` or `comma` as the first argument.

```sh
odds <start> <end> [format]
```

### systemd-boot

Boot into bios menu

```sh
boot-bios
```

List boot entries

```sh
boot-list
```

Boot into a specific entry

```sh
boot-from <entry>
```
