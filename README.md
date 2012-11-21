Virtually
=========

KVM management with [ruby-libvirt](http://libvirt.org/)

Usage
-----

    hypervisor = Virtually.connect 'qemu+ssh://root@tisch.jkraemer.net/system?socket=/var/run/libvirt/libvirt-sock'


    pool = hypervisor.find_storage_pool 'vg0'
    template = pool.find_volume 'template'
    volume = template.clone :name => 'new-volume'
    domain = hypervisor.define_domain :name => 'test-vm',
                                      :disk => { :source => volume.path }
    domain.create

    sleep 5 # wait for domain to get ready
    puts "new guest is online with IP #{domain.ip}"

    # upload some file to guest
    domain.upload 'some/local/file', '/path/in/guest/vm'
    # run command on guest
    puts domain.ssh('hostname')

    # shut down the guest, blocking until it is down.
    domain.shutdown(true)

    # undefine domain and remove volume
    domain.undefine
    volume.destroy


Running the tests
-----------------

You need a working KVM setup to run the tests. Copy
test/config.yml.template to test/config.yml and modify to suit your
environment. 

The user specified as `:ssh_user` will be used to determine the IP address
of a domain. You will need to set up passwordless access for this user
since password based access is not implemented (yet).

The :uri is passed directly to Libvirt.connect, see
http://libvirt.org/uri.html for possible URI formats.

`:test_pool`, `:test_domain` and `:test_volume` should be the names of an
existing storage pool, domain and volume in the environment specified by
URI. Also the 'default' libvirt network should exist in the target
environment.


Determining the IP of a running guest
-------------------------------------

Since libvirt does not offer a way to get the IP address of a running guest by
default, there is some work needed to get this working.

Virtually by default depends on arpwatch running on the Hypervisor and
logging to `/var/log/arpwatch.log`. Whenever `Domain#ip` is called, we
ssh into the host and run Hypervisor#ip_command with the domain's MAC
address as the argument, which will basically grep the log for the mac
address and extract the IP.

*Arpwatch setup (Debian Squeeze)*

    aptitude install arpwatch


/etc/rsyslog.d/arpwatch:

    if $programname =='arpwatch' then /var/log/arpwatch.log


/etc/arpwatch.conf:

    # list all interfaces where VMs might appear
    virbr0
    br0



Restart arpwatch and rsyslog after modifiying their config.

If you want to change the way of determining the guest IP, redefine
`Hypervisor#ip_command`. In case you only use DHCP and no guests with
static IPs it might be a good idea to watch `/var/log/daemon.log` for
DHCPACK messages for the MAC address in question. Arpwatch is not needed
then.


Known Limitations and rough edges
---------------------------------

- Specifying multiple disks and network interfaces per
  guest underwent only limited testing. Use

      :disks => [
        { :source => /path/to/vda-volume, :target_dev => 'vda'},
        { :source => /path/to/vdb-volume, :target_dev => 'vdb'}
      ]

  for multiple disks, and `:network_interfaces` instead of
  `:network_interface` for multiple networks.
- It *should* work to use file based volumes, however since I only use
  LVM volumes (and you really should, too) this is also mostly untested.
- Storage pools cannot be modified, they have to be created upfront.
- no password based ssh / scp, for now you will need to set up your
  hypervisor and guest templates with a proper `authorized_keys` file to
  allow for passwordless authentication for the user specified as
  `:ssh_user`

