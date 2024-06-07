# Dotfiles

This is a collection of my dotfiles and a playbook to install them. Every configuration has its own role and can be installed individually. After running the playbook, you probably need to reboot your system to apply all changes.

```sh
ansible-playbook main.yml --ask-become-pass
```

or use tags to run selectively

```sh
ansible-playbook main.yml --ask-become-pass --tags "sudo"
```

or skip tags to exclude

```sh
ansible-playbook main.yml --ask-become-pass --skip-tags "sudo"
```
