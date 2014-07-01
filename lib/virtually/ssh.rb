require 'net/ssh'
require 'net/scp'

module Virtually

  # adds the ability to run commands on a remote host
  #
  # no support for passwords, set up passwordless login
  # in your host and guest templates to make this work.
  module SSH

    # run the given command on the hypervisor
    def run(command)
      Net::SSH.start(hostname, ssh_user) do |ssh|
        return ssh.exec!(command)
      end
    end

    # uploads file
    def upload(local, remote)
      Net::SCP.upload!(hostname, ssh_user, local, remote)
    end

    # call this after changing ssh host keys
    def remember_new_host_key!
      run "true"
    rescue Net::SSH::HostKeyMismatch => e
      puts "remembering new key: #{e.fingerprint}"
      e.remember_host!
    end


  end
end
