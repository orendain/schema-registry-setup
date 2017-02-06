# Schema Registry Setup

This installs and configures Schema Registry onto your latest HDF Sandbox.  It also installs a NiFi nar for NiFi integration.

Run the following in the sandbox:
```
git clone https://github.com/orendain/schema-registry-setup
./schema-registry-setup/setup-registry.sh
```

That's it!

Note: Since Schema Registry is going to be released in the very near future, this script was written with speed in mind, not necessarily flexibility or to be future-proof.  Lots of hard coded goodness going on in here ;)

