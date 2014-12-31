How To Stand Up A 10-Node CoreOS Cluster With Consul+Registrator In AWS Using Terraform
===
```
$ make
```

To make it easier on yourself, run `cp terraform.tfvars.example terraform.tfvars` and then edit as appropriate.

How To Access Fleet
===
```
$ $(terraform output fleet_env)
$ fleetctl list-machines
```

If you don't have fleetctl and you're on a Mac, you can run `make fleetctl` and it will install it via Homebrew.

How To Access Consul
===
```
$ open $(terraform output consul_url) # assuming again you're on a Mac
```